function fDisp(name,units,numbers)
%FDISP - Displays one or two outputs along with the units that belong with
%them.
% 
% fDisp(name,units,numbers)
%
% name - a string describing a single variable or a two-element sting
% vector.
% units - a string or a two-element string vector that gives the units that 
% go along with the given numbers
% numbers - a number or two-element vector that gives the values to be
% displayed.
%

    fNumbers = string(round(numbers,4, "significant"));
    if isscalar(numbers)
        fprintf('%-20s \t%-5s %s \n', name, fNumbers, units);
    else
        fprintf('%-20s \t%-5s %s \t[%-5s %s]\n', name, fNumbers(1), units(1), fNumbers(2), units(2));
    end
end