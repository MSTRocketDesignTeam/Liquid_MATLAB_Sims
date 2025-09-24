%% Altitude Simulator
% Author: Noah Damery
% Created: Aug 2024
% Modified: 9/22/2025
% Description: This program will take in a given set of input conditions that describe a rocket and predict its altitude.

clc; clear; close;

%% Set up unit conversion factors
mToFt   = double(unitConversionFactor("m", "ft"));
lbfToN  = double(unitConversionFactor("lbf", "N"));
kgToLbm = double(unitConversionFactor("kg", "lbm"));
msToMph = double(unitConversionFactor("m/s", "mi/hr"));
mToMi   = double(unitConversionFactor("m", "mi"));

%% Set up criteria
% The analysis will reject altitude values that do not meet these criteria.
% For a single case sim like this one, there is no point in using this as no optimization is being performed.
arg.minTWR = 0;

%% Input variables 
arg.thrust          = 620   *lbfToN; %      lbf   ->  N     Rocket starting thrust
arg.massFraction    = 0.41   ; %             -     ->  -     Mass fraction (Prop mass/total mass)
arg.propMass        = 47    /kgToLbm; %     lbm   ->  kg    Propellant mass
arg.thrustDecay     = 0     *lbfToN; %      lbf/s ->  N/s   Thrust lost per second (-dt/ds)
arg.dragCoefficient = 0.6   ; %             -     ->  -     Coefficient of drag
arg.diameter        = 6     *2.54/100; %    in    ->  m     Rocket diameter    
arg.startAltitude   = 2000  /mToFt; %       ft    ->  m     Starting altitude (MSL)
arg.isp             = 130   ; %             s     ->  s     Rocket specific impulse
arg.ispDecay        = 0     ; %             s/s   ->  s/s   Specific impulse lost per second
arg.flightAngle     = 12    ; %             deg   ->  deg   Angle of flight
arg.railLength      = 50    /mToFt; %       ft    ->  m     Launch rail length
arg.railButtonDist  = 8     /mToFt; %       ft    ->  m     Rail button distance
arg.m_leftover      = 2     /kgToLbm; %     lbm   ->  kg    Propellant remaining in tanks
arg.dt              = .001  ; %                             Timestep

%% Run Altitude Sim
results = getAltitude(arg);
best = max(max(results.delta_h));
best_index = find(results.delta_h==best, 1);

%% Key Performance Data Outputs
fprintf('\n\nKey Performance Data:\n')
fDisp('Apogee', ["km","kft"], results.delta_h(best_index)*[1/1000, mToFt/1000]);
fDisp('Inital TWR', "g", results.initialTWR(best_index));

%% Input Conditions:
fprintf('\n\nInput Conditions:\n')
fDisp('Initial thrust', ["kN", "lbf"], arg.thrust(best_index)*[1/1000, 1/lbfToN]);
fDisp('Mass fraction', "", arg.massFraction(best_index));
fDisp('Dry mass', ["kg", "lbm"], results.m_dry(best_index)*[1, kgToLbm]);
fDisp('Initial prop mass', ["kg", "lbm"], arg.propMass(best_index)*[1, kgToLbm]);
fDisp('Total mass', ["kg", "lbm"], results.m_total(best_index)*[1, kgToLbm]);
fDisp('Drag coefficient', "", arg.dragCoefficient);

%% Output Conditions
fprintf('\n\nOutput Conditions:\n')
fDisp('Max altitude (MSL)', ["km", "kft"], results.h_max(best_index)*[1/1000, mToFt/1000]);
fDisp('Maximum acceleration', "g", results.a_max(best_index)/9.81);
fDisp('Maximum deceleration', "g", results.de_max(best_index)/9.81);
fDisp('Burn time', "s", results.t_burn(best_index));
fDisp('Time to apogee', "s", results.t_apogee(best_index));
fDisp('Maximum velocity', ["m/s", "mi/hr"], results.v_max(best_index)*[1, msToMph]);
fDisp('Velocity off rail', ["m/s", "ft/s"], results.v_rail(best_index)*[1, mToFt]);
fDisp('Maximum drag', ["kN", "lbf"], abs(results.D_max(best_index))*[1/1000, 1/lbfToN]);
fDisp('Downrange distance', ["km", "mi"], results.l(best_index)*[1/1000, mToMi]);