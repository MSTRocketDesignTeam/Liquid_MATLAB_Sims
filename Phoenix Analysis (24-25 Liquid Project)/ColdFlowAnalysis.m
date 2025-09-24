% Phoenix Injector Test 
% 3/1/2025

clear; 
clc;

lbToKg = double(unitConversionFactor('lb', 'kg'));
psiToPa = double(unitConversionFactor('psi', 'Pa'));

m_bucket = 2.545*lbToKg; % kg

rho = 1000; % kg/m^3

d_ox = .067*2.54/100; % m
d_fu = .042*2.54/100; % m

N_orifices = 20;

A_fuel = 1/4*pi*d_fu^2*N_orifices;
A_ox = 1/4*pi*d_ox^2*N_orifices;
A_both = A_ox + A_fuel;

A = [A_fuel, A_ox, A_both];

m_total = [13.240 18.830 14.695 16.315 14.795 14.990 15.880]*lbToKg; % kg
t       = [10.0   7.0    10.0   5.0    10.0   5.0    4.0   ]; % s
deltaP  = [55     49     78     50     76     49.5   84    ]*psiToPa; % Pa
type    = [1      2      1      2      1      2      3     ]; % 1=Fuel, 2=Ox, 3=Both

m_water = m_total - m_bucket; % kg

mDot = m_water./t; % kg/s

CdA = mDot./(sqrt(2*rho*deltaP)); % m^2

Cd  = CdA./A(type); % -

fuel_avg = mean(Cd(type == 1));
ox_avg = mean(Cd(type == 2));
both_avg = mean(Cd(type == 3));

fprintf('Fuel Average Cd: \t%.3f\n', fuel_avg);
fprintf('Oxidizer Average Cd: \t%.3f\n', ox_avg);
fprintf('Combined Average Cd: \t%.3f\n', both_avg);
