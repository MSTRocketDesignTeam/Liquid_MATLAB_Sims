function outp = getBoltShearStress(arg)
%GETBOLTSTRESS - Calculates the stresses in bolts under given conditions
% 
% outp = getBoltShearStress(inp)
% 
% Returns a struct containing the bearing stress and shear stress of the 
% bolt setup in pascals. This function assumes that there is only one shear 
% plane for each bolt. Make sure that the value for the wall thickness is 
% the thinner of the two walls that are in contact.
%
% Required Values:
% arg.d - Diameter of bolt holes (m)
% arg.t - Thickness of wall (m)
% arg.F - Total force (N)
% arg.n - Number of bolts (-)
%
% Values Returned:
% outp.bearingStress - Bearing stress on hole face (Pa)
% outp.shearStress   - Shear stress on bolt (Pa)

A_b = arg.d*arg.t*arg.n; % m^2 Total bearing area
A_s = 1/4*pi*arg.d^2*arg.n; % m^2 Total shear area
    
outp.bearingStress = arg.F/A_b;
outp.shearStress   = arg.F/A_s;
end