function stresses = getMaxStress(arg)
%GETMAXSTRESS - Get the max compressive stress on the inner wall
%   This calculation is based of of Huzel & Huang, equation 4-31, which
%   gives the maximum total compressive stress in a thin-walled cylinder
%   such as the combustion chamber.
%   arg.OD  - outer diameter          (m) 
%   arg.ID  - inner diameter          (m)
%   arg.P_o - outer pressure          (Pa)
%   arg.P_i - inner pressure          (Pa)
%   arg.E   - Young's Modulus         (Pa)
%   arg.alpha   - Thermal expansion coef. (-)
%   arg.T_o - Outer wall temp         (C, K)
%   arg.T_i - Inner wall temp         (C, K)
%   arg.v   - Poisson's ratio         (-)
%   

t = (arg.OD - arg.ID)/2;

if any(arg.ID./t > 20)
    R = arg.ID/2;

    fprintf('Using thin walled assumption (%f > 20).', min(arg.ID./t));

    stresses.thermalStress = arg.E.*arg.alpha.*(arg.T_o - arg.T_i)./(2*(1-arg.v));
    stresses.pressureStress = (arg.P_i - arg.P_o).*R./t; % Roark's, page 672
else
    a = arg.OD/2;
    b = arg.ID/2;

    outerThermalStress = arg.E.*arg.alpha.*(arg.T_i-arg.T_o)/(2*(1-arg.v)*log(a/b)) ...
        *(1 - (2*b^2)*log(a/b)/(a^2 - b^2)); % Roark's, page 762
    innerThermalStress = arg.E.*arg.alpha.*(arg.T_i-arg.T_o)/(2*(1-arg.v)*log(a/b)) ...
        *(1 - (2*a^2)*log(a/b)/(a^2 - b^2));
    
    % P*b^2*(a^2 + r^2)/(r^2*(a^2 + b^2));
    outerInternalStress = arg.P_i*b^2*(a^2 + a^2)/(a^2*(a^2 + b^2)); % Roark's page 683
    innerInternalStress = arg.P_i*b^2*(a^2 + b^2)/(b^2*(a^2 + b^2));

    % -P*a^2*(b^2 + r^2)/(r^2*(a^2 - b^2));
    outerExternalStress = -arg.P_o*a^2*(b^2 + a^2)/(a^2*(a^2 - b^2));
    innerExternalStress = -arg.P_o*a^2*(b^2 + b^2)/(b^2*(a^2 - b^2));

    outerPressureStress = outerExternalStress + outerInternalStress;
    innerPressureStress = innerExternalStress + innerInternalStress;

    outerStress = outerPressureStress + outerThermalStress;
    innerStress = innerPressureStress + innerThermalStress;

    if abs(outerStress) > abs(innerStress)
        stresses.thermalStress = outerThermalStress;
        stresses.pressureStress = outerPressureStress;
        disp('Outer Stress is greater');
    else
        stresses.thermalStress = innerThermalStress;
        stresses.pressureStress = innerPressureStress;
        disp('Inner Stress is greater');
    end

end


stresses.totalStress = stresses.thermalStress + stresses.pressureStress;
end