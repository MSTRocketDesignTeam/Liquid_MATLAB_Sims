% Phoenix Injector Cold Flow 
% Test Date: 3/9/2025
% Author: Noah Damery

clear; clc; close;

% Displays cropped data plots when set to "false"
suppressPlots = true;

dataTable = readtable('ColdFlowData.xlsx', 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');

orificeTypes = dataTable{:,'Type Number'};
waterMass    = dataTable{:,'Water Mass'};
flowTime     = dataTable{:,'Flow Time'};
startSamples = dataTable{:,'Start Sample'};
endSamples   = dataTable{:,'End Sample'};
testNames    = dataTable{:, 'Data File'};
pressureAdjustment = dataTable{:, 'Pressure Adjustment'};

% Read Average Pressure Data from .csv Files
for i = 1:length(orificeTypes)
    if startSamples(i) ~= 0
        PTPressure(i) = getAveragePressure(testNames(i),startSamples(i), endSamples(i), orificeTypes(i), suppressPlots) + pressureAdjustment(i);
    end
end

PTPressure = PTPressure';

lbToKg = double(unitConversionFactor('lb', 'kg'));
psiToPa = double(unitConversionFactor('psi', 'Pa'));

% Problem Setup
rho = 1000; % kg/m^3
d_ox = .067*2.54/100; % m
d_fu = .043*2.54/100; % m
N_orifices = 20;

% Area Calculations
A_fuel = 1/4*pi*d_fu^2*N_orifices;
A_ox = 1/4*pi*d_ox^2*N_orifices;
A_both = A_ox + A_fuel;

A = [A_fuel; A_ox; A_both];

% Convert to Consistent Units
m_water = waterMass*lbToKg; % kg
t       = flowTime; % s
deltaP  = PTPressure*psiToPa; % Pa
type    = orificeTypes; % 1=Fuel, 2=Ox, 3=Both

mDot = m_water./t; % kg/s

% Perform Cd Calculations
CdA = mDot./(sqrt(2*rho*deltaP)); % m^2
Cd  = CdA./A(type); % -

% Filter Results
fuelSamples = Cd(type == 1);
oxSamples = Cd(type == 2);
bothSamples = Cd(type == 3);

filteredFuelSamples = fuelSamples(fuelSamples ~= inf);
filteredOxSamples = oxSamples(oxSamples ~= inf);
filteredBothSamples = bothSamples(bothSamples ~= inf);

fuelAvg = mean(filteredFuelSamples);
oxAvg = mean(filteredOxSamples);
bothAvg = mean(filteredBothSamples);

% Calculate random error in testing setup (95% Confidence)
fuelError = 2*std(filteredFuelSamples); 
oxError   = 2*std(filteredOxSamples);
bothError = 2*std(filteredBothSamples);

% Display Results
fprintf('Fuel Cd \t%.3f +/- %.3f\n', fuelAvg, fuelError);
fprintf('Oxidizer Cd \t%.3f +/- %.3f\n\n', oxAvg, oxError);

fprintf('Fuel CdA \t%.5f in^2\n', fuelAvg*A_fuel*(100/2.54)^2);
fprintf('Oxidizer CdA \t%.5f in^2\n', oxAvg*A_ox*(100/2.54)^2);
fprintf('Combined CdA \t%.5f in^2\n\n', bothAvg*A_both*(100/2.54)^2);

fprintf('Fuel Trials:\n')
disp(filteredFuelSamples)
fprintf('Oxidizer Trials:\n')
disp(filteredOxSamples)
fprintf('Both Trials:\n')
disp(filteredBothSamples)

function meanPressure = getAveragePressure(testName, startSample, endSample, testType, suppressPlots)
  filename = testName + ".csv"; % Ensure correct filename
  opts = detectImportOptions(filename, 'NumHeaderLines', 22, 'VariableNamingRule', 'preserve'); % Keep original headers
  data = readtable(filename, opts);

  sensor_indices = [];
  sensor_names = {'1KPT#1 (Fuel)', '3KPT#1 (Ox)', '1KPT#1', '3KPT#1'};
  for i = 1:length(sensor_names)
    idx = find(strcmp(data.Properties.VariableNames, sensor_names{i}));
    if ~isempty(idx)
        sensor_indices = [sensor_indices, idx];
    end
  end

  % Check if any sensor columns were found
  if isempty(sensor_indices)
    error('No relevant sensor columns found. Check column names.');
  end

  sensor_data = data{:, sensor_indices};

  switch testType
    case {1}
      meanPressure = mean(sensor_data(startSample:endSample,1));
    case {2}
      meanPressure = mean(sensor_data(startSample:endSample,2));
    case {3}
      meanPressure = mean(vertcat(sensor_data(startSample:endSample,1), sensor_data(startSample:endSample,2)));
    end

    if ~suppressPlots
        figure();
        plot(1:length(sensor_data), sensor_data(:,1), 1:length(sensor_data), sensor_data(:,2), 'LineWidth', 2);
        xlabel('Sample Number', 'fontsize', 12);
        ylabel('Pressure (psig)', 'fontsize', 12);
        title(testName);
        xline(startSample, "LineWidth", 2);
        xline(endSample, "LineWidth", 2);
        yline(meanPressure, "LineWidth", 2);
        legend('Fuel Pressure', 'Ox Pressure');
        ax = gca();
        set(ax,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
    end
end