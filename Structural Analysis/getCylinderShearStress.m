function cylinderShear = getCylinderShearStress(arg)
%GETBOLTTEAROUTSTRESS - Calculates the shear stress in a 
% 
% cylinderShear = getCylinderShearStress(arg)
% 
% Required Values:
% arg.D_shear - Diameter of shear cylinder
% arg.L_shear - Length of shear cylinder
% arg.F_shear - Shearing force
%
% Values Returned:
% cylinderShear - Shear stress in section (MPa)

A_shear = pi*arg.D_shear*arg.L_shear; % m^2    Total shear area
cylinderShear = arg.F_shear/A_shear;
end