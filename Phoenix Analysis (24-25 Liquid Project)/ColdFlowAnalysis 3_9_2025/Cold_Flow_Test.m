
% Load the data with preserved column names
filename = ['CFFuel5.csv']; % Ensure correct filename
opts = detectImportOptions(filename, 'NumHeaderLines', 22, 'VariableNamingRule', 'preserve'); % Keep original headers
data = readtable(filename, opts);

% Display available column names to debug potential issues
disp('Column Names Detected:');
disp(data.Properties.VariableNames);

% Define sensor column names and corresponding units
sensor_names = {'1KPT#1 (Fuel)', '3KPT#1 (Ox)', '5KPT#1', '5KPT#2', 'LOADCELL'};
sensor_units = {'psi', 'psi', 'psi', 'psi', 'lbs'}; % Define respective units

% Find the indices of the relevant columns
sensor_indices = [];
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

% Extract sensor data
sensor_data = data{:, sensor_indices};

% Convert sensor data to numeric values
sensor_data = str2double(string(sensor_data));

% Assume time increments by 0.001 seconds per sample
num_samples = size(sensor_data, 1);
time = (0:num_samples-1)' * 0.001; % Time in seconds

% Convert units
conversion_factors = [0.000145038, 0.000145038, 0.000145038, 0.000145038, 0.224809]; % psi for KPT sensors, lbs for LOADCELL
for i = 1:length(sensor_indices)
    sensor_data(:, i) = sensor_data(:, i) * conversion_factors(i);
end

% Initialize arrays for results
max_values = zeros(1, length(sensor_indices));
burn_durations = zeros(1, length(sensor_indices));
avg_above_threshold = zeros(1, length(sensor_indices));

% Compute metrics for each sensor
for i = 1:length(sensor_indices)
    max_values(i) = max(sensor_data(:, i)); % Maximum value
    threshold = 0.15 * max_values(i); % 15% of maximum
    
    % Find indices where sensor value is above the threshold
    above_threshold_idx = sensor_data(:, i) > threshold;
    
    % Compute burn duration
    burn_durations(i) = sum(above_threshold_idx) * 0.001; % Convert sample count to time
    
    % Compute average value while above threshold
    avg_above_threshold(i) = mean(sensor_data(above_threshold_idx, i));
    
    % Display results
    fprintf('Sensor: %s\n', sensor_names{i});
    fprintf('  Maximum: %.3f %s\n', max_values(i), sensor_units{i});
    fprintf('  Burn Duration: %.3f s\n', burn_durations(i));
    fprintf('  Average Above 15%%: %.3f %s\n\n', avg_above_threshold(i), sensor_units{i});
end

% Plot each sensor on a separate figure
for i = 1:length(sensor_indices)
    figure;
    plot(time, sensor_data(:, i), 'b');
    xlabel('Time (s)');
    ylabel([sensor_names{i}, ' (', sensor_units{i}, ')']);
    title(['Raw Data - ', sensor_names{i}]);
    grid on;
end

% Fix sampling frequency calculation
fs = 1 / 0.001; % Since time increments by 0.001s, fs = 1000 Hz

% Apply low-pass filter
fc = 5; % Cutoff frequency (adjust as needed)
[b, a] = butter(4, fc / (fs / 2), 'low'); % 4th order Butterworth filter

filtered_data = sensor_data;
for i = 1:size(filtered_data, 2)
    filtered_data(:, i) = filtfilt(b, a, filtered_data(:, i));
end

% Plot each filtered sensor on a separate figure
for i = 1:length(sensor_indices)
    figure;
    plot(time, filtered_data(:, i), 'r');
    xlabel('Time (s)');
    ylabel([sensor_names{i}, ' (', sensor_units{i}, ')']);
    title(['Filtered Data - ', sensor_names{i}]);
    grid on;
end