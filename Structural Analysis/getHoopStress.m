function hoopStress = getHoopStress(arg)
%GETHOOPSTRESS - Calculates the stresses in bolts under given conditions
% 
% Using vessel outer diameter yields a conservative approximation.
% 
% hoopStress = getHoopStress(arg)
% 
% Required Values:
% arg.d - Diameter of vessel (m)
% arg.t - Thickness of wall (m)
% arg.P - Internal pressure (Pa)
%
% Values Returned:
% hoopStress - Hoops stress in wall

if arg.d/arg.t < 20
    warning(['This calculator uses the equation for stress in a thin ' ...
        'walled pressure vessel, but the dimensions that have been ' ...
        'input are not a thin shell. The diameter to thickness ratio ' ...
        'is less than 20.']);
end

hoopStress = arg.P.*arg.d./(arg.t.*2);
end