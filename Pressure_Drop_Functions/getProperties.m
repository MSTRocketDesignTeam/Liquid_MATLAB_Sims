function [density, viscosity] = getProperties(fluid, temperature)
    %Gets the density and viscosity of a fluid based on the type of fluid
    %and the temperature (assuming incompressible or saturated liquid for now)

    % Gets properties of nitrous
    if strcmp(fluid, 'Nitrous')
        properties = readtable('N20_Property_Table.dat', 'ReadVariableNames',true, VariableNamingRule='preserve');

        if rem(temperature,1) == 0 && temperature >= -131 && temperature <= 97
            % Locate row of desired properties
            row_finder = properties.T == temperature;
            row = find(row_finder);
            density = properties.("ρ(l)")(row);
            viscosity = properties.("µ")(row)/1000;
        elseif temperature <= 97 && temperature >= -131
            lowtemp = floor(temperature);
            hightemp = ceil(temperature);
            lowrow = properties.T == lowtemp;
            highrow = properties.T == hightemp;
            temp_between = (temperature - lowtemp)/(hightemp - lowtemp);

            density = lininterp(properties.("ρ(l)")(lowrow), properties.("ρ(l)")(highrow), temp_between);
            viscosity = lininterp(properties.("µ")(lowrow), properties.("µ")(highrow), temp_between)/1000;
        else
            fprintf('Please enter a temperature value between -131 and 97 degrees Farenheight')
            return
        end

    % Gets properties of ethanol
    elseif strcmp(fluid, 'Ethanol')
        density = 789;
        viscosity = .00125;
    end
end