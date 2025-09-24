function [h_l, V_fuel, A_fuel] = getLiquidCoefficient(OD, ID, coolant, mDot_fuel)
%GETLIQUIDCOEFFICIENT - Calculates the liquid heat transfer coefficient
%   OD        - Outer diameter of coolant passage
%   ID        - Inner diameter of coolant passage
%   coolant   - Struct of coolant properties including c, rho, mu, & kappa
%   mDot_fuel - Coolant mass flow rate 

A_fuel = .25*pi*OD.^2-.25*pi*ID.^2; %  m^2       Regen cross sectional area
D_equiv = 4*A_fuel./(pi*ID); %                m         Equivalent Diameter
V_fuel = mDot_fuel./(coolant.rho*A_fuel); %      m/s       Coolant velocity


h_l = 0.023 * coolant.c * (mDot_fuel ./ A_fuel) ...
    .* (D_equiv .* V_fuel .* coolant.rho / coolant.mu).^(-0.2) ...
    * (coolant.mu * coolant.c / coolant.kappa)^(-2/3); 
% This formula from RPE yields a value that is ~14% lower than 
% Heat Transfer Example 8.5. This is acceptable since the value 
% in this simulation is more conservative and is given by the 
% formula that is from RPE. (Checked on 8/4/2024)
end