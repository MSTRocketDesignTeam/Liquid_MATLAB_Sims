function table = untitled15(choiceName, h_g, h_l, T_g, T_l, kappa, t_w)
%GENERATECOMPARISONTABLE - Generates a table to show deviations in wall
%temps.
%   choiceName options:
%   "RPE_Default"
%   "None"
%   "Worst_Case"
%
%   h_g - Gas heat transfer coefficient
%   h_l - Liquid heat transfer coefficient
%

mults.RPE_Default = {[.5;1;2;4;1;1;1;1], [1;1;1;1;.5;.25;.125;.0625]};
mults.None        = {1, 1};
mults.Worst_Case  = {[1;2;4], [1;.5;.25]};
mults.choice = mults.(choiceName);

gMult = mults.choice{1};
lMult = mults.choice{2};

h_gVec = gMult * h_g; 
h_lVec = lMult * h_l;

datum = getWallTemps(h_g, h_l, T_g, T_l, kappa, t_w);

comp = getWallTemps(h_gVec,h_lVec, T_g, T_l, kappa, t_w);

comparison = [...
    gMult*100, lMult*100, comp.q/datum.q*100, ...
    comp.T_wg_C, comp.T_wl_C,comp.T_wg_C - comp.T_wl_C...
    ]; 

table = array2table(comparison, ...
    'VariableNames',{'Gas Coef. (%)', 'Liquid Coef. (%)', ...
    'Heat Transfer Change (%)', 'Gas Side, results.T_w (C)', 'Liquid Side, T_l (C)', 'Delta T (C)'})
end