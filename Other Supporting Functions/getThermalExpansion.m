function totalExpansion = getThermalExpansion(arg)
%GETTHERMALEXPANSION - Returns the linear thermal expansion of an element subjected to a temperature change.
% expansion = getThermalExpansion(args)
% Returns the linear thermal expansion present in an object that is heated 
% under the given conditions. Args is a struct that must contain the 
% following properties: 

% L – Initial length of the object
% a - Thermal expansion coefficient
% deltaT - Temperature difference from start length to current condition.

% All values are given and returned in consistent units.
%
% For more information, see the detailed documentation.

totalExpansion = arg.L.*arg.a.*arg.deltaT;
end