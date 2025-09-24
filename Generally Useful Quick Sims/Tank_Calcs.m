%Tank MATLAB Script

clear
clc

%Configure Characteristics
mass_nitrous = 45; % (lbm)
mass_ethanol = 15; % (lbm)
mass_tot = mass_ethanol+mass_nitrous; % (lbm)
mass_frac = mass_nitrous/mass_ethanol; % O:F Ratio
density_ethanol = 789; % (kg/m^3)
density_nitrous = 726.59; % (kg/m^3)
density_ethanol = density_ethanol / 27680; % (lbm/in^3)
density_nitrous = density_nitrous / 27680; % (lbm/in^3)
tank_OD = 5; % (in)
tank_thickness = .125; % (in)
piston_thickness = .5; % (in)
piston_length = 3; % (in)
bulkhead_indepth = 2; % (in)

%Calculated values
tank_csarea = pi/4 * (tank_OD - 2*tank_thickness)^2; % (in^2)

mass_ethanol = mass_tot / (mass_frac + 1); % (lbm)
mass_nitrous = mass_ethanol * mass_frac; % (lbm)

vol_ethanol = mass_ethanol / density_ethanol; % (in^3)
vol_nitrous = mass_nitrous / density_nitrous; % (in^3)

nitrous_length = vol_nitrous / tank_csarea; % (in)
ethanol_length = vol_ethanol / tank_csarea; % (in)
tot_length = nitrous_length + ethanol_length + piston_thickness + 2*bulkhead_indepth;

svent_loc = nitrous_length + bulkhead_indepth - (piston_length-piston_thickness);

% Results
fprintf('Ethanol Mass: %g lbm\n', mass_ethanol)
fprintf('Nitrous Mass: %g lbm\n', mass_nitrous)
fprintf('Ox Tank Length: %g in\n', nitrous_length)
fprintf('Fuel Tank Length: %g in\n', ethanol_length)
fprintf('Total Length: %g in\n', tot_length)
fprintf('The static vent hole should be %g in from the bottom of the tank\n', svent_loc)