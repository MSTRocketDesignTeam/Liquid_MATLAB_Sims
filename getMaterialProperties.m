function material = getMaterialProperties(materialName)
%GETMATERIALPROPERTIES Returns material properties of given material
% 
% materialMatrix = getMaterialProperties(materialName)
% 
% Returns a struct of material properties of the material given in the 
% “materialName” parameter, including the following variables. All values 
% are returned in SI units, when applicable (temperatures in Celsius). 
% All properties except yield strength are either given for a constant 
% temperature of approximately 20 C (293 K, 68 F) or they are given for 
% more conservative temperatures.
% 
% Values Returned:
% Kappa   - Conductivity (W/m-K)
% rho     - Density (kg/m^3)
% a       - Thermal expansion coefficient (m/m-C)
% v       - Poisson’s ratio (-)
% solidus – Solidus melting point (C)
% yield   - [INTERNAL] Yield values across temperatures (Pa)
% temps   - [INTERNAL] Temperature values for yields (C)
% 
% Functions Returned:
% getYieldStrength(temperature)
% -	Returns the yield strength of the material at the given temperature in Pa.
% -	Temperature inputs must be in C.
% 
% getYoungsModulus(temperature)
% -	Returns the Young’s modulus of the material at the given temperature in Pa.
% -	Temperature inputs must be in C.
% 
% Supported Materials and their Abbreviations:
% Stainless Steel 304 – “steel304”
% Alloy Steel 4340 – “steel4340”
% Aluminum 6061 – “aluminum6061”
% Aluminum 7075 – “aluminum7075”
% 
% 
% For information on data sources, see the extended documentation.

% STAINLESS STEEL 304 -----------------------------------------------------
materials.steel304.kappa   = 16.2; % at 0-100 C (increases with temperature, so this is worst case)
materials.steel304.rho     = 8000; 
materials.steel304.a       = 18.7*10^-6; % at 650 C
materials.steel304.v       = 0.29;
materials.steel304.solidus = 1400;
materials.steel304.yield   = [20,20,17.9,15.7,14.1,13,12.4,12.2,11.9,...
    11.75,11.55,11.3,11.05,10.8,10.55,10.3,9.75,7.7,6.05]*6.895*10^6; %  Design limit strength (lower than yield strength)
materials.steel304.temps   = [24,38,93,149,204,260,316,343,371,399,427,...
    454,482,510,538,566,593,621,649];
materials.steel304.getYoungsModulus = ...
    @(T) interp1([0,600],[29,21.5],T,"linear")*...
    double(unitConversionFactor("psi", "Pa"))*10^6;
materials.steel304.getYieldStrength = ...
    @(T) interp1(materials.steel304.temps, materials.steel304.yield, T);
materials.steel304.message = "Recorded yield values are considerably " + ...
    "conservative for stainless 304.";

% ALUMINUM 6061 -----------------------------------------------------------
materials.al6061.kappa   = 167;
materials.al6061.rho     = 2700;
materials.al6061.a       = 25.2*10^-6; % at up to 300C
materials.al6061.E       = 68.9*10^9; % at room temp
materials.al6061.v       = 0.33;
materials.al6061.solidus = 582;
materials.al6061.y_temps = [24,100,149,204,260,316,371];
materials.al6061.yield   = [276,262,214,103,34,19,12]*10^6;
materials.al6061.e_temps = [20, 50,100, 150,200,250,300,350,400,550];
materials.al6061.modulus = [70,69.3,67.9,65.1,60.2,54.6,47.6,37.8,28,0]*10^9;
materials.al6061.getYieldStrength = ...
    @(T) interp1(materials.al6061.y_temps, materials.al6061.yield, T);
materials.al6061.getYoungsModulus = @(T) interp1(materials.al6061.e_temps, materials.al6061.modulus, T);
materials.al6061.message = "WARNING: The Young's modulus of aluminum 6061 " + ...
    "used here is assumed to be very close to the typical values for all " + ...
    "aluminums during a two-hour exposure period. " + ...
    "This is NOT a conservative assumption for 6061 aluminum. ";

% ALUMINUM 7075 -----------------------------------------------------------
materials.al7075.kappa   = 130;
materials.al7075.rho     = 2810;
materials.al7075.a       = 25.2*10^-6; % At up to 300 C (conservative)
materials.al7075.v       = 0.33;
materials.al7075.solidus = 475;
materials.al7075.y_temps = [25,100,150,205,260,315,370];
materials.al7075.yield   = [505,450,185,90,60,45,32]*10^6;

materials.al7075.e_temps = [20, 50,100, 150,200,250,300,350,400,550];
materials.al7075.modulus = [70,69.3,67.9,65.1,60.2,54.6,47.6,37.8,28,0]*10^9;
materials.al7075.getYieldStrength = @(T) interp1(materials.al7075.y_temps, materials.al7075.yield, T);
materials.al7075.getYoungsModulus = @(T) interp1(materials.al7075.e_temps, materials.al7075.modulus, T);
materials.al7075.message = "WARNING: The Young's modulus of aluminum 7075 " + ...
    "used here is assumed to be very close to the typical values for all " + ...
    "aluminums during a two-hour exposure period. " + ...
    "This is NOT a conservative assumption for 7075 aluminum. ";

% ALLOY STEEL 4340 --------------------------------------------------------
materials.steel4340.kappa   = 44.5; %        W/m-K       Conductivity 
materials.steel4340.rho     = 7850; %       kg/m^3      Density
materials.steel4340.a       = 13.9*10^-6; % m/m-C       Thermal expansion coefficient
materials.steel4340.v       = 0.29; %       -           Poisson's ratio
materials.steel4340.temps   = [20,100,200,300,400,500,600,700,800,900,1000,1100,1200]; % C   Temps for temp vs yield graph
materials.steel4340.yield   = [1,1,.807,.613,.42,.36,.18,.075,.05,.0375,.025,.125,0]*862*10^6; %   MPa Yield for temp vs yield graph
materials.steel4340.modulus = [1,1,.9,.8,.7,.6,.310,.130,.090,.0675,.045,.0225,0]*200*10^9;
materials.steel4340.getYieldStrength = @(T) interp1(materials.steel4340.temps, materials.steel4340.yield, T);
materials.steel4340.getYoungsModulus = @(T) interp1(materials.steel4340.temps, materials.steel4340.modulus, T);
materials.steel4340.message = "";

% STAINLESS STEEL 303 -----------------------------------------------------
materials.steel303.kappa   = 16.2; %        W/m-K       Conductivity 
materials.steel303.rho     = 8000; %       kg/m^3      Density
materials.steel303.a       = 18.7*10^-6; % m/m-C       Thermal expansion coefficient
materials.steel303.v       = 0.29; %       -           Poisson's ratio
materials.steel303.temps   = [25,425,540,650,760,870]; % C   Temps for temp vs yield graph
materials.steel303.yield   = [240,240,235,205,145,70]*10^6; %   MPa Yield for temp vs yield graph
materials.steel303.modulus = 193*10^9;
materials.steel303.getYieldStrength = @(T) interp1(materials.steel303.temps, materials.steel303.yield, T);
materials.steel303.getYoungsModulus = @(T) materials.steel303.modulus;


disp(materials.(materialName).message);
material = materials.(materialName);
end