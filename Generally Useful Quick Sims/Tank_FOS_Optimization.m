% Eric Miranda
% Missouri S&T Rocket Design Team

clear
clc

% Load in Bolt Properties from dat file
bolt_properties = readtable('Bolt_Properties.dat', 'ReadVariableNames',true, VariableNamingRule='preserve');
bolt_clearance = readtable('Bolt_Holes.dat', 'ReadVariableNames',true, VariableNamingRule='preserve');


% 6061-T6 Aluminum Strength Characteristics
Al_tensile_yield = 40000; % (psi)
Al_tensile_ult = 45000; % (psi)
Al_bearing_yield = 56000; % (psi)
Al_bearing_ult = 88000; % (psi)
Al_shear_strength = 30000; % (psi)

% Variables that will not change
OD = 6; % (in)
wall_thickness = .125; % (in)
ID = OD - 2*wall_thickness; % (in0)
MEOP = 900; % (psi)
min_FS = 1.5;

% Variables that can change
screw_num = 12;
screw_tensile_strength = 60000; % (psi)
screw_shear_strength = screw_tensile_strength * .6; % (psi)
center_edge_distance = .7; % (in)

    % Screw Type Variables
    Bolt.name = bolt_properties.Thread;
    Bolt.MinorDiameter = bolt_properties.("Basic minor dia of ext. threads (inches)"); % (in)
    Bolt.HoleDiameter = zeros(length(Bolt.name),1);
    for i = 1:length(Bolt.name)
        ScrewType = bolt_properties.Type(i);
        RowClearance = find(strcmp(ScrewType, bolt_clearance.Type));
        Bolt.HoleDiameter(i) = bolt_clearance.MinDC(RowClearance);
    end
    E_min = center_edge_distance - Bolt.HoleDiameter./2; % (in)

% Stress Calcs
hoop_stress = MEOP * ((OD+ID)/2)/2 / wall_thickness; % (psi)
shear_stress = pi/4 * ID^2 .* MEOP ./ (screw_num .* pi/4 .* Bolt.MinorDiameter.^2);
force_bolt = pi/4 * ID^2 .* MEOP ./ screw_num; % (lbf)
tearout_stress = force_bolt ./ (E_min .* 2.*wall_thickness);
tensile_stress = pi/4*ID^2.*MEOP./((pi*(OD-wall_thickness) - screw_num.*Bolt.HoleDiameter).*wall_thickness);
stress_bearing = force_bolt ./ (Bolt.HoleDiameter.*wall_thickness);

% Factor of Safety Calcs
hoop_yFS = Al_tensile_yield ./ hoop_stress;
hoop_uFS = Al_tensile_ult ./ hoop_stress;
shear_FS = screw_shear_strength ./ shear_stress;
tearout_FS = Al_shear_strength ./ tearout_stress;
tensile_yFS = Al_tensile_yield ./ tensile_stress;
tensile_uFS = Al_tensile_ult ./ tensile_stress;
bearing_yFS = Al_bearing_yield ./ stress_bearing;
bearing_uFS = Al_bearing_ult ./ stress_bearing;

% Outputs
%fprintf('Hoop Yield FS: %g\n', hoop_yFS)
%fprintf('Hoop Ultimate FS: %g\n', hoop_uFS')
%fprintf('Bolt Shear FS: %g\n', shear_FS)
%fprintf('Bolt Tearout FS: %g\n', tearout_FS)
%fprintf('Tensile Yield FS: %g\n', tensile_yFS)
%fprintf('Tensile Ultimate FS: %g\n', tensile_uFS)
%fprintf('Bearing Yield FS: %g\n', bearing_yFS)
%fprintf('Bearing Ultimate FS: %g\n', bearing_uFS)

% Graphs
% figure(1)
% plot(screw_num, shear_FS, 'g', 'LineWidth', 2)
% hold on
% plot(screw_num, bearing_yFS, 'b', 'LineWidth', 2)
% plot(screw_num, tensile_yFS, 'k', 'LineWidth', 2)
% plot(screw_num, tearout_FS, 'm', 'LineWidth', 2)
% plot(screw_num, hoop_yFS .* ones(length(screw_num)), 'r', 'LineWidth', 2)
% plot(screw_num, min_FS * ones(length(screw_num)), '--')
% title('Yield Factors of Safety vs. Number of Bolts')
% xlabel('Number of Bolts')
% ylabel('Factors of Safety')
% legend('Shear', 'Bearing', 'tensile', 'tearout', 'hoop', 'Location', 'southeast')

figure(2)
plot(bolt_properties.Index, shear_FS, '.g')
hold on
plot(bolt_properties.Index, bearing_yFS, '.b')
plot(bolt_properties.Index, tensile_yFS, '.k')
plot(bolt_properties.Index, tearout_FS, '.m')
plot(bolt_properties.Index, hoop_yFS .* ones(length(bolt_properties.Index)), 'r')
plot(bolt_properties.Index, min_FS * ones(length(bolt_properties.Index)), 'k--')
title('Yield Factors of Safety vs. Bolt Type')
xlabel('Bolt')
ylabel('Factors of safety')
legend('Shear', 'Bearing', 'tensile', 'tearout', 'hoop', 'Location', 'northeast')
ylim([0 5])
xticks(1:length(Bolt.name))
xticklabels(bolt_properties.Thread)
grid on

figure(3)
plot(bolt_properties.Index, shear_FS, '.g')
hold on
plot(bolt_properties.Index, bearing_uFS, '.b')
plot(bolt_properties.Index, tensile_uFS, '.k')
plot(bolt_properties.Index, tearout_FS, '.m')
plot(bolt_properties.Index, hoop_uFS .* ones(length(bolt_properties.Index)), 'r')
plot(bolt_properties.Index, min_FS * ones(length(bolt_properties.Index)), 'k--')
title('Ultimate Factors of Safety vs. Bolt Type')
xlabel('Bolt')
ylabel('Factors of safety')
legend('Shear', 'Bearing', 'tensile', 'tearout', 'hoop', 'Location', 'northeast')
ylim([0 5])
xticks(1:length(Bolt.name))
xticklabels(bolt_properties.Thread)
grid on