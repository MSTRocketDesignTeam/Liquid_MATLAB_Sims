function tearOutStress = getBoltTearOutStress(arg)
%GETBOLTTEAROUTSTRESS - Calculates the stresses in bolts under given conditions
% 
% tearOutStress = getBoltTearOutStress(arg)
% 
% Required Values:
% arg.d_maj - Diameter of bolt holes (m)
% arg.t     - Thickness of wall (m)
% arg.F     - Total force (N)
% arg.n     - Number of bolts (-)
% arg.E     - Center distance from edge of wall (m) 
%
% Values Returned:
% tearOutStress - Tear out Stress on bolt (Pa)

A_t = 2*arg.t*(arg.E - arg.d_maj/2)*arg.n; % m^2    Total tear out area
tearOutStress = arg.F/A_t;
end