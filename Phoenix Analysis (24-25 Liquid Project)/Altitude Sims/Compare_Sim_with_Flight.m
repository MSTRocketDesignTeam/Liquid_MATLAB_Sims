%% Comparing Flight Data with Sim
% Author: Noah Damery
% Created: 09/24/2025
% Modified: 09/24/2025

% clc; clear; close;

filterWindow = 70;

%% Get Accel from Retroactive Phoenix Sim

% Set up unit conversion factors
mToFt   = double(unitConversionFactor("m", "ft"));
lbfToN  = double(unitConversionFactor("lbf", "N"));
kgToLbm = double(unitConversionFactor("kg", "lbm"));
msToMph = double(unitConversionFactor("m/s", "mi/hr"));
mToMi   = double(unitConversionFactor("m", "mi"));

% Set up criteria
% The analysis will reject altitude values that do not meet these criteria.
% For a single case sim like this one, there is no point in using this as no optimization is being performed.
arg.minTWR = 0;

% Input variables 
arg.thrust          = 580   *lbfToN; %      lbf   ->  N     Rocket starting thrust
arg.massFraction    = 0.42   ; %             -     ->  -     Mass fraction (Prop mass/total mass)
arg.propMass        = 45    /kgToLbm; %     lbm   ->  kg    Propellant mass
arg.thrustDecay     = 28     *lbfToN; %      lbf/s ->  N/s   Thrust lost per second (-dt/ds)
arg.dragCoefficient = 0.45  ; %             -     ->  -     Coefficient of drag
arg.diameter        = 6     *2.54/100; %    in    ->  m     Rocket diameter    
arg.startAltitude   = 2000  /mToFt; %       ft    ->  m     Starting altitude (MSL)
arg.isp             = 115   ; %             s     ->  s     Rocket specific impulse
arg.ispDecay        = 0     ; %             s/s   ->  s/s   Specific impulse lost per second
arg.flightAngle     = 12    ; %             deg   ->  deg   Angle of flight
arg.railLength      = 50    /mToFt; %       ft    ->  m     Launch rail length
arg.railButtonDist  = 8     /mToFt; %       ft    ->  m     Rail button distance
arg.m_leftover      = 10     /kgToLbm; %     lbm   ->  kg    Propellant remaining in tanks
arg.dt              = .001  ; %                             Timestep

% Run Altitude Sim
results     = getAltitude(arg);
best        = max(max(results.delta_h));
best_index  = find(results.delta_h==best, 1);

% Key Performance Data Outputs
fprintf('\n\nKey Performance Data:\n')
fDisp('Apogee', ["km","kft"], results.delta_h(best_index)*[1/1000, mToFt/1000]);
fDisp('Inital TWR', "g", results.initialTWR(best_index));

% Input Conditions:
fprintf('\n\nInput Conditions:\n')
fDisp('Initial thrust', ["kN", "lbf"], arg.thrust(best_index)*[1/1000, 1/lbfToN]);
fDisp('Mass fraction', "", arg.massFraction(best_index));
fDisp('Dry mass', ["kg", "lbm"], results.m_dry(best_index)*[1, kgToLbm]);
fDisp('Initial prop mass', ["kg", "lbm"], arg.propMass(best_index)*[1, kgToLbm]);
fDisp('Total mass', ["kg", "lbm"], results.m_total(best_index)*[1, kgToLbm]);
fDisp('Drag coefficient', "", arg.dragCoefficient);

% Output Conditions
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

%% Read Blue Raven Data
% Comment the next line to improve execution speed after the first read
% ravenData = readtable('PhoenixRavenData.xlsx');

% Blue Raven Deployment Time
deploymentTime = 44;

% Process Blue Raven Data
a = horzcat(ravenData{:,"Accel_X"}, ravenData{:,"Accel_Y"}, ravenData{:,"Accel_Z"});
t_raven = ravenData{:, "Flight_Time__s_"};
a_mag_raven = -a(:,1) - 1; % * Blue raven reads 1 g while on the pad, so this must be subtracted. 
a_mag_raven_filter = conv(a_mag_raven,ones(1,filterWindow)/filterWindow,"same");

%% Read Telemetrum Data
% Comment the next line to improve execution speed after the first read
% teleData = readtable('PhoenixTelemetrumData.xlsx');

% Process Telemetrum Data
a_mag_tele = teleData{:, "acceleration"}/9.81;
t_tele = teleData{:, "time"};
a_mag_tele_filter = conv(a_mag_tele,ones(1,filterWindow)/filterWindow,"same");
alt_tele = teleData{:,"altitude"};
v_tele = teleData{:, "speed"};

%% Plot Accelerations
fig1 = figure();
plot(t_raven,a_mag_raven_filter, 'LineWidth', 2);
hold on
plot(results.time,results.accel/9.81, 'LineWidth', 2);
plot(t_tele,a_mag_tele_filter, 'LineWidth', 2);
axis([0,50,-2,7]);
xline(results.t_burn, "Color", "red");
xline(results.t_apogee, "Color", "red");
xline(deploymentTime, "Color", "b"); 
xlabel('Flight Time (s)', 'fontsize', 12);
ylabel('Accelration Magnitude (g)', 'fontsize', 12);
title('Acceleration Magnitude');
ax1 = gca();
set(fig1, 'Name', 'Acceleration Magnitude');
set(ax1,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig1, './figures/Compare_Sim_with_Flight Acceleration Magnitude.png');

%% Altitude Plot
fig2 = figure();
plot(results.time,results.alt, 'LineWidth', 2);
hold on
plot(t_tele, alt_tele, 'LineWidth', 2);
xlabel('Time (s)', 'fontsize', 12);
ylabel('Altitude (m)', 'fontsize', 12);
title('Altitude Plot');
ax2 = gca();
set(fig2, 'Name', 'Altitude Plot');
set(ax2,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig2, './figures/Compare_Sim_with_Flight Altitude Plot.png');

%% Plot Velocity
fig3 = figure();
plot(t_tele,v_tele, 'LineWidth', 2);
xlabel('Time (s)', 'fontsize', 12);
ylabel('Velocty (m/s)', 'fontsize', 12);
title('Plot Velocity');
ax3 = gca();
set(fig3, 'Name', 'Plot Velocity');
set(ax3,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig3, './figures/Compare_Sim_with_Flight Plot Velocity.png');
