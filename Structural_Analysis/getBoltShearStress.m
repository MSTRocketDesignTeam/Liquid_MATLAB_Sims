function shearStress = getBoltShearStress(arg)
%GETBOLTSHEARSTRESS - Calculates the stresses in bolts under given conditions
% 
% shearStress = getBoltShearStress(arg)
% 
% Required Values:
% arg.d_min - Minor diameter of bolt holes (m)
% arg.F     - Total force (N)
% arg.n     - Number of bolts (-)
%
% Values Returned:
% shearStress   - Shear stress on bolt (Pa)

A_s = 1/4*pi*arg.d_min^2*arg.n; %              m^2    Total shear area
shearStress   = arg.F/A_s;
end