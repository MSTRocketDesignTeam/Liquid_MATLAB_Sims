function bearingStress = getBoltBearingStress(arg)
%GETBOLTBEARINGSTRESS - Calculates the stresses in bolts under given conditions
% 
% outp = getBoltBearingStress(arg)
% 
% Required Values:
% arg.d_maj - Major diameter of bolt holes (m)
% arg.t     - Thickness of wall (m)
% arg.F     - Total force (N)
% arg.n     - Number of bolts (-)
%
% Values Returned:
% bearingStress - Bearing stress on hole face (Pa)

A_b = arg.d_maj.*arg.t.*arg.n; %                 m^2    Total bearing area
bearingStress = arg.F./A_b;
end