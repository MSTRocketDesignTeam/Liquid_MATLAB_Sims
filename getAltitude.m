function r = getAltitude(arg)
%GETALTITUDE - Returns an estimate of the rocket's apogee based on given
%input conditions.
%
% r = getAltitude(opt, const, crit)
% This function is designed to be able to be used as an altitude optimizer. 
% It can take in a variety of input condition ranges and output altitudes 
% for all of them. You can then find the input conditions that produced the
% best results and build a rocket based on those. 
% 
% In order to do an optimization, you could input an n-dimensional matrix 
% for each field where there are n variables being optimized and each 
% direction in the matrix corresponds to changes in one variable. This 
% function will run all of the simulations simultaneously to improve 
% calculation time and spit out an n-dimensional matrix of solutions.  
% Such a matrix can be generated quite easily using the 
% getOptimixationMatrix function. 
% 
% If the min TWR condition is not met for a given case then it's apogee 
% will be set to zero - excluding it from coming out of the optimization 
% as a reasonable choice.
%
% The r field is a struct containing all the named function results.
%
% A timestep of 0.01 seconds is recommended for this function. Higher 
% timesteps result in higher calculation times, but you will start 
% getting noticeable error in the thousands of feet by decreasing your 
% sim timestep to ~1 second.
% 
% Required Values: 
% arg.dragCoefficient - Coefficient of drag (-)
% arg.diameter        - Rocket diameter (m)
% arg.startAltitude   - Starting altitude above MSL (m)
% arg.isp             - Rocket specific impulse (s)
% arg.ispDecay        - Specific impulse lost per second (s/s)
% arg.flightAngle     - Angle of flight (deg)
% arg.railLength      - Launch rail length (m)
% arg.railButtonDist  - Rail button distance (m)
% arg.m_leftover      - Propellant remaining in tanks (kg)
% arg.dt              - Timestep for running simulation (s)
%
% arg.thrust            - Rocket starting thrust (N)
% arg.massFraction      - Mass fraction {Prop mass/total mass} (-)
% arg.propMass          - Propellant mass (kg)
% arg.thrustDecay       - Thrust lost per second due to blow down (N/s)
%
% arg.minTWR           - Min TWR 
%
% Values Returned:
% r.delta_h             - Apogee (m)
% r.t_burn              - Total burn time (s)
% r.v_max               - Maximum velocity (m/s)
% r.v_rail              - Velocity when first rail button leaves rail (m/s)
% r.a_max               - Maximum acceleration (m/s^2)
% r.de_max              - Maximum deceleration (m/s^2)
% r.D_max               - Maximum drag (N)
% r.h_max               - Max altitude {apogee + starting altitude} (m)
% r.l                   - Lateral distance traveled at given angle (m)
% r.t_apogee            - Time to apogee (s)
% r.initialTWR          - TWR at start of burn (-)
%

    tic;
    T = arg.thrust; %                 N         Initial thrust
    T_decay = arg.thrustDecay; %      N/s       Amount of thrust lost per second
    zeta = arg.massFraction;%         -         Propellant mass fraction
   
    % User variables
    h_start = arg.startAltitude; %  m         Initial altitude   
    isp = arg.isp; %                s         Initial specific impulse
    isp_decay = arg.ispDecay; %     s/s       Specific impulse lost per second
    d = arg.diameter; %             m         Rocket diameter
    C_D = arg.dragCoefficient; %    -         Coefficient of drag

    % Calculated variables
    A = .25.*pi.*d.^2; %              m^2       Rocket cross-sectional area
    m_prop = arg.propMass; %          kg        Propellant mass
    m_dry = m_prop.*(1-zeta)./zeta;%   kg        Rocket dry mass
    m_total = m_dry + m_prop; %       kg        Rocket total mass

    % Initialize Constants
    g = 9.81; %                 m/s^2     Gravitational acceleration

    % Initialize Changing Variables
    h = h_start; %              m         Current altitude 
    v = 0; %                    m/s       Current velocity
    a = 0; %                    m/s^2     Current acceleration
    D = 0; %                    m         Current drag
    m = m_total; %              kg        Current mass
    l = 0; %                    m         Estimated horizontal distance

    % Set up max variables
    v_max = 0;
    a_max = 0;
    D_max = 0;
    h_max = 0;
    de_max = 0;
    v_rail = 0;
    
    % Iteration setup
    dt = arg.dt; %            s         Simulation time step 
    t = 0; %                  s         Elapsed mission time
    t_burn = 0;
    flying = 1;

    reps = 0;

    wb = waitbar(0, 'Starting Burns... (0%)');

    while any(flying,"all") % When the rocket reaches apogee, stop simulating
        burning = (m > m_dry + arg.m_leftover) & (T > T_decay.*dt); % Creates a logical matrix of which simulations are still burning
        flying = v >= 0; % Creates a logical matrix of which simulations are still flying
        t_burn = t_burn + burning.*dt; % Adds burn time to all remaining simulations

        reps = reps + 1; % For progress bar updates
        if mod(reps, floor(1./dt)) == 0 && toc > .1
            if any(burning, "all")
                progress = min((m_total - m)./(m_prop-arg.m_leftover), [], 'all');
                waitbar(progress, wb, sprintf('Simulations Burning... (%.0f%%)', progress.*100));
            elseif any(flying, "all")
                progress = min(1-v./v_max, [], 'all');
                waitbar(progress, wb, sprintf('Simulations Coasting... (%.0f%%)', progress.*100));
            end
        end


        % Calculate Decays 
        % - Updates thrust and isp as pressures decrease
        T = (T - T_decay.*dt).*(T > T_decay.*dt); % Don't let the thrust dip below 0
        isp = isp - isp_decay.*dt;

        T = T.*burning; % If the rocket has burnt out, set thrust to zero

        % Calculate Mass
        % - Updates the rocket's total mass by subtracting the mass flowing
        %   through the nozzle
        mDot = T./(g.*isp);
        m = m - mDot.*dt;

        % Calculate Drag
        % - Updates drag as the rocket moves higher in the atmosphere and
        %   gains velocity
        rho = getRho(h);
        D = -.5.*rho.*v.^2.*A.*C_D;

        % Dynamics
        % - Updates the net force on the rocket and its acceleration.
        F = D + T - m.*g;
        a = F./m.*flying; % Only update if you're still burning

        % Kinematics
        % - Updates the rocket's position and altitude.
        % - Updates mission elapsed time
        v = a.*dt.*flying + v; % Only update if you're still burning
        h = v.*dt.*flying.*cosd(arg.flightAngle) + h;
        t = t + dt.*flying;

        % Track horizontal distance
        % - This ignores wind so it's probably a pretty bad estimate
        % - Think about this more as a minimum distance for a given angle
        l = l + v.*dt.*flying.*sind(arg.flightAngle); 

        v_max = max(v, v_max);
        a_max = max(a, a_max);
        de_max = min(a, de_max);
        D_max = min(D, D_max);
        h_max = max(h, h_max);

        onRail = (h - arg.startAltitude < arg.railLength - arg.railButtonDist);
        v_rail = max(v_rail, v.*onRail);
    end

    if any(burning)
        warning(['In some sims, the rocket might fall out of the sky while still ' ...
            'burning due to a lack of thrust.'])
    end

    if any(m > m_dry + arg.m_leftover)
        warning(['In some sims, the rocket''s thrust is reduced to ' ...
            'zero before all propellant is utilzized. Either decrease ' ...
            'thrust decay, increase thrust, or decrease propellant mass ' ...
            'to a reasonable value'])
    end
    
    % Results summary struct
    r.t_burn = t_burn;
    r.v_max = v_max;
    r.v_rail = v_rail;
    r.a_max = a_max;
    r.de_max = de_max;
    r.D_max = D_max;
    r.h_max = h_max;
    r.l     = l;
    r.t_apogee = t;
    r.initialTWR = arg.thrust./m_total./g;
    r.m_dry = m_dry;
    r.m_total = m_total;

    acceptable = arg.minTWR <= r.initialTWR;
    if any(~acceptable)
        warning(['Some flights have been thrown out due to the criteria' ...
            ' not being met.'])
    end

    r.delta_h = (h - h_start).*acceptable;
    
    close(wb);

    toc;
end