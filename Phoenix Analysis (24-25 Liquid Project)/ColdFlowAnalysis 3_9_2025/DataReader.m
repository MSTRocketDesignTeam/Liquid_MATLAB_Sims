filename = ['CFFuel2.csv']; % Ensure correct filename
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

plot(1:length(sensor_data), sensor_data(:,1), 1:length(sensor_data), sensor_data(:,2));


datvec = sensor_data(:,2);
% Get test start and end points
delta = vertcat(datvec, [0]) - (vertcat([0], datvec));
big = (abs(delta) - mean(abs(delta)) - .25*std(abs(delta)))>0;
find(big)
sum(big)
