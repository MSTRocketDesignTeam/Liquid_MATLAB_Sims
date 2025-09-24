clc; clear; close all;

%% Variables
rho = 0.036127; % (Density of water, pound per cubic inch, lb/in^3)
m = input("Please input total mass in pounds: ")/32.2; % Convert to slugs
t = input("Please input total time for mass to acummulate: ");
deltaP = input("Please input pressure drop in psi: ");

%% Calculations
m_dot = (m/t); % Mass flow rate

CdA = (m/(t*sqrt(2*deltaP*rho))); % Discharge coefficient

A_ox = pi/4*0.067^2*10;
A_fuel = pi/4*0.042^2*10;


%% Outputs
fprintf("CdA (in^2): %.5f\n", CdA);
fprintf("Cd_fuel: %.2f\n", CdA/A_fuel);
fprintf("Cd_oxidizer: %.2f\n", CdA/A_ox);


