% Altitude Estimator
clear; clc; tic;

% Set up unit conversion factors
mToFt   = double(unitConversionFactor("m", "ft"));
lbfToN  = double(unitConversionFactor("lbf", "N"));
kgToLbm = double(unitConversionFactor("kg", "lbm"));
msToMph = double(unitConversionFactor("m/s", "mi/hr"));
mToMi   = double(unitConversionFactor("m", "mi"));

sd = 1; % Simulation dimension
fprintf('Analyzing %d cases...\n\n', sd^2);

% Set up criteria
% - The analysis will reject altitude values that do not meet these criteria
crit.minTWR = 6.0;

% Set up optimization variables
opt.thrust = ones(sd,sd).*linspace(750, 750, sd)*lbfToN;
opt.massFraction = ones(sd,sd).*transpose(linspace(.4,.4,sd));

% Future variables for more optimization
opt.propMass = 30*ones(sd,sd); % kg     Propellant mass
opt.thrustDecay = 40; %          N/s    Thrust lost per second

% Other input variables
% ----------------------vvv--- Input numbers in indicated column only 
%                        v
const.dragCoefficient = 0.7  ; %          -     Coefficient of drag
const.diameter        = 6     *2.54/100; % in   Rocket diameter    
const.startAltitude   = 2000  /mToFt; %    ft   Starting altitude (MSL)
const.isp             = 200   ; %          s    Rocket specific impulse
const.ispDecay        = 0     ; %          s/s  Specific impulse lost per second
const.flightAngle     = 10    ; %          deg  Angle of flight
const.railLength      = 40    /mToFt; %    ft   Launch rail length
const.railButtonDist  = 4     ; %          m    Rail button distance

[results, inputs] = getAltitude(opt, const, crit);
best = max(max(results.delta_h));
best_index = find(results.delta_h==best, 1);

fprintf('\nInput Conditions:\n');
cdisp('Initial thrust', ["kN", "lbf"], inputs.T(best_index)*[1/1000, 1/lbfToN]);
cdisp('Mass ratio', "", inputs.zeta(best_index));
cdisp('Dry mass', ["kg", "lbm"], inputs.m_dry(best_index)*[1, kgToLbm]);
cdisp('Initial prop mass', ["kg", "lbm"], inputs.m_prop(best_index)*[1, kgToLbm]);
cdisp('Total mass', ["kg", "lbm"], inputs.m_total(best_index)*[1, kgToLbm]);
cdisp('Drag coefficient', "", inputs.C_D);

fprintf('\nOutput Conditions:\n');
cdisp('Apogee', ["km","kft"], results.delta_h(best_index)*[1/1000, mToFt/1000]);
cdisp('Max altitude (MSL)', ["km", "kft"], results.h_max(best_index)*[1/1000, mToFt/1000]);
cdisp('Inital TWR', "g", results.initialTWR(best_index));
cdisp('Maximum acceleration', "g", results.a_max(best_index)/9.81);
cdisp('Maximum deceleration', "g", results.de_max(best_index)/9.81);
cdisp('Burn time', "s", results.t_burn(best_index));
cdisp('Time to apogee', "s", results.t_apogee(best_index));
cdisp('Maximum velocity', ["m/s", "mi/hr"], results.v_max(best_index)*[1, msToMph]);
cdisp('Velocity off rail', ["m/s", "ft/s"], results.v_rail(best_index)*[1, mToFt]);
cdisp('Maximum drag', ["kN", "lbf"], abs(results.D_max(best_index))*[1/1000, 1/lbfToN]);
cdisp('Downrange distance', ["km", "mi"], results.l(best_index)*[1/1000, mToMi]);

fprintf('\n'); toc;

function cdisp(name,units,numbers)
    fNumbers = string(round(numbers,4, "significant"));
    if isscalar(numbers)
        fprintf('%-20s \t%-5s %s \n', name, fNumbers, units);
    else
        fprintf('%-20s \t%-5s %s \t[%-5s %s]\n', name, fNumbers(1), units(1), fNumbers(2), units(2));
    end
end

getRho(23000)
function rho = getRho(h)
    h_ref = [0, 1000, 2000, 3000, ...
        4000, 5000, 6000, 7000, ...
        8000, 9000, 10000, 11000, ...
        12000, 13000, 14000, 15000, ...
        16000, 17000, 18000, 19000, ...
        20000, 30000, 40000, 50000,...
        60000, 70000, 80000];
    rho_ref = [1.225, 1.112, 1.007, .9093, ...
        .8194, .7364, .6601, .5900, ...
        .5258, .4671, .4135, .3648, ...
        .3119, .2666, .2279, .1948, ...
        .1665, .1423, .1217, .1040, ...
        .08891, .01841, .003996, .001027, ...
        .0003097, .00008283, .00001846];

    if h > 80000
        rho = 0;
    elseif h < 0
        error('The altitude cannot be below 0 msl');
    else
        rho = interp1(h_ref, rho_ref, h, "linear");
    end
end

function [r, inp] = getAltitude(opt, const, crit)
    T = opt.thrust; %                 N         Initial thrust
    T_decay = opt.thrustDecay; %      N/s       Amount of thrust lost per second
    zeta = opt.massFraction;%         -         Propellant mass fraction
   
    % User variables
    h_start = const.startAltitude; %  m         Initial altitude   
    isp = const.isp; %                s         Initial specific impulse
    isp_decay = const.ispDecay; %     s/s       Specific impulse lost per second
    d = const.diameter; %             m         Rocket diameter
    C_D = const.dragCoefficient; %    -         Coefficient of drag

    % Calculated variables
    A = .25*pi*d.^2; %                m^2       Rocket cross-sectional area
    m_prop = opt.propMass; %          kg        Propellant mass
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
    dt = 0.01; %                s         Simulation time step 
    t = 0; %                    s         Elapsed mission time
    t_burn = 0;
    flying = 1;

    while any(flying,"all") % When the rocket reaches apogee, stop simulating
        burning = m > m_dry; % Creates a logical matrix of which simulations are still burning
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
        h = v.*dt.*flying*cosd(const.flightAngle) + h;
        t = t + dt.*flying;

        % Track horizontal distance
        % - This ignores wind so it's probably a pretty bad estimate
        % - Think about this more as a minimum distance for a given angle
        l = l + v.*dt.*flying*sind(const.flightAngle); 

        v_max = max(v, v_max);
        a_max = max(a, a_max);
        de_max = min(a, de_max);
        D_max = min(D, D_max);
        h_max = max(h, h_max);

        onRail = (h - const.startAltitude < const.railLength - const.railButtonDist);
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
    r.initialTWR = opt.thrust./m_total./g;

    acceptable = crit.minTWR <= r.initialTWR;
    if any(~acceptable)
        warning(['Some flights have been thrown out due to the criteria' ...
            ' not being met.'])
    end

    r.delta_h = (h - h_start).*acceptable;

    % Input recap struct
    inp.T = opt.thrust;
    inp.zeta = opt.massFraction;
    inp.m_prop = opt.propMass;
    inp.C_D = const.dragCoefficient;
    inp.m_dry = m_dry;
    inp.m_total = m_total;
end