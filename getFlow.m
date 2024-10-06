function outp = getFlow(arg)
%GETFLOW - Solves for the flow properties of the injector orifices
% 
% outp = getFlow(arg)
% 
% Returns a struct of flow properties for a given set of input properties. 
% If mass flow rate is passed in, then this function solves for orifice 
% area and diameter. If orifice area is passed in, then this function 
% solves for the mass flow rate. The math for this function is based on RPE
% Equations 8-1 and 8-2 which can be found on page 280 of the 9th Edition. 
% These equations are technically only valid for single phase flow. 
% 
% Required Values:
% arg.mDot*      - Total orifice group mass flow rate (kg/s)
% arg.A*	     - Individual orifice area (m^2)
% 
% arg.C_d        - Orifice discharge coefficient (-)
% arg.rho        - Fluid density at orifice (kg/m^3)
% arg.deltaP     – Pressure drop across the orifices (Pa)
% arg.N_orifices – Number of orifices in group (-)
% 
% Values Returned: 
% outp.A*        - Individual orifice area (m^2)
% outp.d*        - Individual orifice diameter (m)
% outp.mDot* 	- Total orifice group mass flow rate (kg/s)
% 
% outp.Q  		- Total orifice group volume flow rate (m^3/s)
% outp.v		- Orifice exit velocity (m/s)
% 
% All values marked with an asterisk can be either input or output values 
% depending on which variables are passed into the function, as described 
% above.
% 
% For more information, see the extended documentation


if isfield(arg, 'mDot')
    outp.A = arg.mDot./(arg.C_d.*sqrt(2.*arg.rho.*arg.deltaP))./arg.N_orifices;
    outp.d = sqrt(4./pi.*outp.A);
    outp.Q = arg.C_d.*outp.A.*arg.N_orifices.*sqrt(2.*arg.deltaP./arg.rho);
    outp.v = outp.Q./(outp.A.*arg.N_orifices);
else
    outp.Q = arg.C_d.*arg.A.*arg.N_orifices.*sqrt(2.*arg.deltaP./arg.rho);
    outp.mDot = outp.Q.*arg.rho;
    outp.v = outp.Q./(arg.A.*arg.N_orifices);
end
end