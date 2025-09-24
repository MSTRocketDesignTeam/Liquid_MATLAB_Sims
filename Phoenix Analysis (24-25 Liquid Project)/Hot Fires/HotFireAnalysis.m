% Noah Damery
% 4/25/2025

clc; clear; close;

% data = readtable('PhoenixHF01-Raw.csv');
data = importdata("./PhoenixHF01-Raw.csv");

oxTank  = data.data(:,14);
fuTank  = data.data(:,12);
chamber = data.data(:,15);
fuLine  = data.data(:,11);
oxLine  = data.data(:,10);
thrust  = data.data(:,17);
x       = data.data(:,1);

%% Thrust
fig1 = figure();
plot(x,thrust, 'LineWidth', 2);
xlabel('Time (s)', 'fontsize', 12);
ylabel('Thrust (lbf)', 'fontsize', 12);
title('Thrust');
ax1 = gca();
set(fig1, 'Name', 'Thrust');
set(ax1,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig1, './figures/FailedHotFireAnalysis Thrust.png');


%% Chamber Pressure
fig2 = figure();
% plot(x, smoothdata(chamber, "movmean"));
plot(x,conv(chamber,ones(1,100)*.01, 'same'), 'LineWidth', 2);
xlabel('Time (s)', 'fontsize', 12);
ylabel('Chamber Pressure (psi)', 'fontsize', 12);
title('Chamber Pressure');
ax2 = gca();
set(fig2, 'Name', 'Chamber Pressure');
set(ax2,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig2, './figures/FailedHotFireAnalysis Chamber Pressure.png');

%% Tank Pressure
fig3 = figure();
plot(x,oxTank, 'LineWidth', 2);
hold on
plot(x,fuTank, 'LineWidth', 2);
legend("Oxidizer", "Fuel")
xlabel('Time (s)', 'fontsize', 12);
ylabel('Ox Tank Pressure (psi)', 'fontsize', 12);
title('Tank Pressure');
ax3 = gca();
set(fig3, 'Name', 'Tank Pressure');
set(ax3,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig3, './figures/FailedHotFireAnalysis Tank Pressure.png');

%% Line Pressure
fig4 = figure();
plot(x,oxLine, 'LineWidth', 2);
hold on
plot(x,fuLine, 'LineWidth', 2);
legend("Oxidizer", "Fuel")
xlabel('Time (s)', 'fontsize', 12);
ylabel('Line Pressure (raw)', 'fontsize', 12);
title('Line Pressure');
ax4 = gca();
set(fig4, 'Name', 'Line Pressure');
set(ax4,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig4, './figures/FailedHotFireAnalysis Line Pressure.png');

%% Chamber + Tank Pressure
fig5 = figure();
% plot(x, smoothdata(chamber, "movmean"));
plot(x,chamber, 'LineWidth', 2);
hold on
plot(x,oxTank, 'LineWidth', 2);
plot(x,fuTank, 'LineWidth', 2);
xlabel('Time (s)', 'fontsize', 12);
ylabel('Chamber Pressure (psi)', 'fontsize', 12);
title('Chamber Pressure');
ax5 = gca();
set(fig5, 'Name', 'Chamber Pressure');
set(ax5,'xgrid','on','ygrid','on','box','off', 'fontsize',18,'linewidth',1);
% saveas(fig2, './figures/FailedHotFireAnalysis Chamber Pressure.png');
legend("Chamber", "Oxidizer", "Fuel")