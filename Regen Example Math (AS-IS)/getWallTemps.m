function output = getWallTemps(h_g, h_l, T_g, T_l, kappa, t_w)
%GETWALLTEMPS - Perform heat transfer analysis with given values
%   h_g   - Gas heat transfer coefficient
%   h_l   - Liquid heat transfer coefficient
%   T_g   - Gas temp
%   T_l   - Liquid temp
%   kappa - Wall thermal conductivity
%   t_w   - Wall thickness

output.q      = (T_g - T_l)./...
    (1./h_g + t_w./kappa + 1./h_l);           % Validated by RPE Example 8.5 on 8/4/2024             
output.T_wg_C = T_g - output.q./h_g - 273.15; % Validated by RPE Example 8.5 on 8/4/2024 
output.T_wl_C = T_l + output.q./h_l - 273.15; % Validated by RPE Example 8.5 on 8/4/2024
end