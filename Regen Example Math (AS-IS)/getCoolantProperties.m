function coolant = getCoolantProperties(coolantName)
%GETCOOLANTPROPERTIES - Gets fluid properties for a given coolant (fuel) selection.
% coolant = getCoolantProperties(coolantName)
% Returns a struct containing coolant properties of the coolant specified 
% by the coolantName parameter. The properties returned are as follows: 
% constant pressure specific heat (c), density (rho), dynamic or absolute 
% viscosity (mu), thermal conductivity (kappa), and boiling temperature at 
% 1 atm (T_boil). All values are returned in SI units, when applicable, and 
% the temperature values are returned in kelvin. All temperature dependent 
% values are given for a temperature of approximately 20 Celsius (293 K, 68 F).
% 
% Supported Coolant Names:
% Ethanol – “ethanol”
% Isopropanol – “isopropanol”

% Properties for ethanol are from:
%   https://www.engineeringtoolbox.com/ethanol-ethyl-alcohol-properties-C2H6O-d_2027.html. 
% Properties for isopropanol are from: 
%   https://www.matweb.com/search/datasheet.aspx?matguid=7d8c7f1164124ddc827eb662d6da7943&ckck=1.


coolants.ethanol.c          = 2.57*10^3; %       J/kg-K    Constant pressure specific heat capacity of ethanol
coolants.ethanol.rho        = 785.3; %           kg/m^3    Density of ethanol
coolants.ethanol.mu         = 1.074*10^-3; %     Pa-s      Dynamic (absolute) viscosity of ethanol at 25 C
coolants.ethanol.kappa      = 0.167; %           W/m-K     Thermal conductivity
coolants.ethanol.T_boil     = 351.39; %          K         Boiling point

coolants.isopropanol.c      = 2.995*10^3; %      J/kg-K    Constant pressure specific heat capacity of ethanol
coolants.isopropanol.rho    = 785.5; %           kg/m^3    Density of ethanol
coolants.isopropanol.mu     = 2.31*10^-3; %      Pa-s      Dynamic (absolute) viscosity of ethanol at 25 C
coolants.isopropanol.kappa  = 0.135; %           W/m-K     Thermal conductivity
coolants.isopropanol.T_boil = 82.4+273.15; %     K         Boiling point

coolant = coolants.(coolantName);
end