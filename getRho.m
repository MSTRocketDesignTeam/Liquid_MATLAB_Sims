function rho = getRho(h)
%GETRHO - Gets the density at a given height in the atmosphere.
% 
% rho = getRho(h)
% 
% Returns the atmospheric density in pascals for a given altitude in
% meters. Valid for altitudes from 0-80,000 m. At altitudes above 80,000 m,
% this function returns 0. This function’s source gives density at a given 
% geopotential altitude – not at a given geometric altitude, but the 
% differences should be small enough to be negligible.
% 
% Required Value: 
% h - altitude above sea level (m)
%
% Value Returned:
% rho - density at given altitude (kg/m^3)
%
% For details on data sources, see the extended documentation.
% 

    h_ref = [0, 1000, 2000, 3000, ...
        4000, 5000, 6000, 7000, ...
        8000, 9000, 10000, 11000, ...
        12000, 13000, 14000, 15000, ...
        16000, 17000, 18000, 19000, ...
        20000, 30000, 40000, 50000,...
        60000, 70000, 80000];
    rho_ref = [1.225, 1.112, 1.007, .9093, ...
        .8194, .7364, .6601, .5900, ...
        .5258, .4671, .4135, .3648, ...
        .3119, .2666, .2279, .1948, ...
        .1665, .1423, .1217, .1040, ...
        .08891, .01841, .003996, .001027, ...
        .0003097, .00008283, .00001846];

    if isUnit(h/.1)
        rho = str2symunit('kg/m^3');
    elseif h > 80000
        rho = 0;
    elseif h < 0
        error('The altitude cannot be below 0 msl');
    else
        rho = interp1(h_ref, rho_ref, h, "linear");
    end
end