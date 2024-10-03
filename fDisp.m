function fDisp(name,units,numbers)
    fNumbers = string(round(numbers,4, "significant"));
    if isscalar(numbers)
        fprintf('%-20s \t%-5s %s \n', name, fNumbers, units);
    else
        fprintf('%-20s \t%-5s %s \t[%-5s %s]\n', name, fNumbers(1), units(1), fNumbers(2), units(2));
    end
end