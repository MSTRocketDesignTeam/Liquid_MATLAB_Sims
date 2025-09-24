function varargout = getGasCoefficient(args)
%GETGASCOEFFICIENT Calculates the estimated value of the combustion gas heat transfer coefficient.
% 
% h_g = getGasCoefficient(args)
% 
% Returns the value of the gas heat transfer coefficient h_g for a given 
% set of input parameters stored in the struct args. This function uses RPE 
% equation 8-20 on page 313 in the 9th edition, although similar formulas 
% can be found in other rocketry texts. This formula is called out in the 
% detailed documentation. The Nusselt number is calculated as a function of 
% the Reynold’s number and the Prandtl number, and then the Nusselt number’s 
% formula can be solved for h_g. To perform all these calculations, the 
% following parameters are required:
% 
%   rho   - Gas density
%   v     - Gas velocity
%   kappa - Gas thermal conductivity
%   mu    - Gas absolute (dynamic) viscosity
%   c_p   - Gas specific heat at constant pressure
%   D     - Interior diameter of chamber/nozzle
% 
% All input and output values can be evaluated using any consistent unit system.
%
% The Prandtl number and the Nusselt number are also available as optional output values.
% 
% The fundamental calculations in this example have been verified by an
% example in "Fundamentals of Heat and Mass Transfer" Bergman & Lavine, 
% 8th edition - example 8.6.


Pr  = args.c_p.*args.mu./args.kappa; % Verified by Heat Transfer ex. 8.6 on 8/2/2024
Re  = args.D.*args.v.*args.rho./args.mu; % Verified by Heat Transfer ex 8.6 on 8/2/2024
Nu  = 0.023*Re.^0.8.*Pr.^0.4; % Verified by Heat Transfer ex 8.6 on 8/2/2024
h_g = Nu.*args.kappa./args.D; % Verified by Heat Transfer ex 8.6 on 8/2/2024

switch nargout
    case {1}
        varargout = h_g;
    case {2}
        varargout = {h_g, Pr};
    case {3}
        varargout = {h_g, Pr, Nu};
end

end