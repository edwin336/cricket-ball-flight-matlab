%% CRICKET_BALL_FLIGHT  Release-to-bounce simulation with drag and a crude swing force
% Coordinates: x down the pitch, y lateral (off side +), z vertical (up).
% Requires: ball_ode.m, ground_event.m, simulate_flight.m (base MATLAB only).
clear; clc; close all;

%% Parameters (SI units)
% --- Ball ---
p.m     = 0.160;    % ball mass (kg), MCC Law 4 range 0.1559-0.163
p.d     = 0.072;    % ball diameter (m), from circumference 0.224-0.229 m
p.rho   = 1.225;    % air density (kg/m^3), ISA sea level 15 C
p.CD    = 0.45;     % drag coefficient (-), held constant
p.seam_deg = 20;   % seam angle to the flow (deg); 20 deg is the calibration angle, sign flips swing direction
p.CS_fun  = build_CS_fun(p.seam_deg);   % C_S(v) incl. seam-angle scaling (see build_CS_fun.m, seam_factor.m)

% --- Derived ---
p.A     = pi*(p.d/2)^2;   % frontal cross-sectional area (m^2)

% --- Environment ---
p.g     = 9.81;     % gravitational acceleration (m/s^2)

% --- Delivery geometry ---
p.z0      = 2.2;    % release height (m)
p.x_stump = 18.9;   % release-to-stumps distance (m), reference only
p.x_bounce = p.x_stump - 6.5;   % target bounce distance from release (m), good length

% --- Release speeds ---
v0_list = [25 30 35 40];   % m/s

%% Run simulations (release angle solved per speed so every ball pitches at p.x_bounce)
n = numel(v0_list);
res = cell(1, n);
theta_deg = zeros(1, n);   % release angle below horizontal (deg)
for k = 1:n
    pk = p;
    pk.theta = solve_release_angle(v0_list(k), p);
    theta_deg(k) = rad2deg(pk.theta);
    res{k} = simulate_flight(v0_list(k), pk);
end

%% Plots
kmh = v0_list*3.6;          % m/s -> km/h
mph = v0_list/0.44704;      % m/s -> mph
labels = arrayfun(@(k) sprintf('%d m/s (%.0f km/h, %.0f mph)', ...
    v0_list(k), kmh(k), mph(k)), 1:n, 'UniformOutput', false);
cols = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.13 0.55 0.13; 0.49 0.18 0.56];   % blue, orange, green, purple: all legible on white
styles = {'-', '--', '-.', ':'};   % distinct line styles so overlapping curves stay visible

fig = figure('Color', 'w', 'Position', [100 100 1000 700]);

% Side view (x vs z)
ax1 = subplot(2, 1, 1); hold(ax1, 'on');
for k = 1:n
    plot(ax1, res{k}.s(:,1), res{k}.s(:,3), 'LineWidth', 1.8, 'Color', cols(k,:), 'LineStyle', styles{k});
end
xline(ax1, p.x_stump, 'k--', 'Stumps', 'LabelVerticalAlignment', 'bottom');
yline(ax1, 0, 'k-');
xlabel(ax1, 'Distance down pitch, x (m)'); ylabel(ax1, 'Height, z (m)');
title(ax1, 'Side view'); lgd = legend(ax1, labels, 'Location', 'northeast');
grid(ax1, 'on'); box(ax1, 'on'); style_axes(ax1); set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');

% Top view (x vs y)
ax2 = subplot(2, 1, 2); hold(ax2, 'on');
for k = 1:n
    plot(ax2, res{k}.s(:,1), res{k}.s(:,2), 'LineWidth', 1.8, 'Color', cols(k,:), 'LineStyle', styles{k});
    plot(ax2, res{k}.xb, res{k}.yb, 'o', 'MarkerSize', 6, 'MarkerFaceColor', cols(k,:), 'MarkerEdgeColor', 'k');   % bounce point
end
xline(ax2, p.x_stump, 'k--', 'Stumps', 'LabelVerticalAlignment', 'bottom');
xlabel(ax2, 'Distance down pitch, x (m)'); ylabel(ax2, 'Lateral position, y (m)');
title(ax2, 'Top view (off side positive; y axis exaggerated)');
grid(ax2, 'on'); box(ax2, 'on'); style_axes(ax2);

% print(fig, 'ball_flight.png', '-dpng', '-r300');   % uncomment to export

%% Summary table (values at first bounce)
fprintf('\n%-10s %-10s %-10s %-12s %-16s %-14s %-14s\n', ...
    'v0 (m/s)', 'km/h', 'mph', 'Angle (deg)', 'Flight time (s)', 'Bounce x (m)', 'Lateral dev (m)');
for k = 1:n
    fprintf('%-10.1f %-10.1f %-10.1f %-12.2f %-16.3f %-14.2f %-14.3f\n', ...
        v0_list(k), kmh(k), mph(k), theta_deg(k), res{k}.tb, res{k}.xb, res{k}.yb);
end

function style_axes(ax)
% Force light-theme axes so the figure is print-ready even in MATLAB dark mode.
set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.2 0.2 0.2], 'FontSize', 12);
ax.Title.Color = 'k'; ax.XLabel.Color = 'k'; ax.YLabel.Color = 'k';
end


