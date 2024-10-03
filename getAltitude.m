function [r, inp] = getAltitude(arg)
%GETALTITUDE - Returns an estimate of the rocket's apogee based on given
%input conditions.
%
% [r, inp] = getAltitude(opt, const, crit)
% 
% This function is designed to be able to be used as an altitude optimizer.
% It could take in a variety of input condition ranges and output altitudes
% for all of them. You can then find the input conditions that produced the
% best results and build a rocket based on those. 
%
% In order to do an optimization, you could input an n-dimensional matrix 
% for each field where there are n variables being optimized and each direction
% in the matrix corresponds to changes in one variable. This function will
% run all of the simulations simultaneously to improve calculation time and
% spit out an n-dimensional matrix of solutions.
% 
% If the min TWR condition is not met for a given case then it's apogee 
% will be set to zero - excluding it from coming out of the optimization 
% as a reasonable choice.
%
% The r field contains all of the function results, and the inp field
% returns all of the key input conditions that correspond to each
% solution so that once the maximum apogee is found, the conditions that
% yielded that apogee can be found in the corresponding input matrix.
%
% A timestep of 0.01 is recommended for this function.
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
% arg.massFraction      - Mass fraction {Dry mass/total mass} (-)
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
% inp.T                 - Input thrust (N)
% inp.zeta              - Input mass fraction (-)
% inp.C_D               - Drag coefficient (-)
% inp.m_prop            - Propellant mass (kg)
% inp.m_dry             - Dry mass (kg)
% inp.m_total           - Total mass (kg)
%

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
    A = .25*pi*d.^2; %                m^2       Rocket cross-sectional area
    m_prop = arg.propMass; %          kg        Propellant mass
    m_dry = m_prop.*zeta./(1-zeta);%  kg        Rocket dry mass
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
    t = 0; %                    s         Elapsed mission time
    t_burn = 0;
    flying = 1;

    while any(flying,"all") % When the rocket reaches apogee, stop simulating
        burning = m > m_dry + arg.m_leftover; % Creates a logical matrix of which simulations are still burning
        flying = v >= 0; % Creates a logical matrix of which simulations are still flying
        t_burn = t_burn + burning.*dt; % Adds burn time to all remaining simulations

        % Calculate Decays 
        % - Updates thrust and isp as pressures decrease
        T = T - T_decay.*dt;
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
        h = v.*dt.*flying*cosd(arg.flightAngle) + h;
        t = t + dt.*flying;

        % Track horizontal distance
        % - This ignores wind so it's probably a pretty bad estimate
        % - Think about this more as a minimum distance for a given angle
        l = l + v.*dt.*flying*sind(arg.flightAngle); 

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

    acceptable = arg.minTWR <= r.initialTWR;
    if any(~acceptable)
        warning(['Some flights have been thrown out due to the criteria' ...
            ' not being met.'])
    end

    r.delta_h = (h - h_start).*acceptable;

    % Input recap struct
    inp.T = arg.thrust;
    inp.zeta = arg.massFraction;
    inp.m_prop = arg.propMass;
    inp.C_D = arg.dragCoefficient;
    inp.m_dry = m_dry;
    inp.m_total = m_total;
end