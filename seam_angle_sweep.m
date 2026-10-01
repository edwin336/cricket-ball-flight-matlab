%% SEAM_ANGLE_SWEEP  Lateral deviation at the bounce vs seam angle, for each release speed.
% Each point re-solves the release angle so the ball still pitches at p.x_bounce.
clear; clc; close all;

p.m = 0.160;  p.d = 0.072;  p.rho = 1.225;  p.CD = 0.45;   % same as main script
p.A = pi*(p.d/2)^2;  p.g = 9.81;
p.z0 = 2.2;  p.x_stump = 18.9;  p.x_bounce = p.x_stump - 6.5;

v0_list  = [25 30 35 40];            % m/s
seam_deg = -30:5:30;                 % seam angle (deg); negative = seam tilted the other way
dev = zeros(numel(v0_list), numel(seam_deg));   % lateral deviation at bounce (m)

for j = 1:numel(seam_deg)
    pj = p;
    pj.CS_fun = build_CS_fun(seam_deg(j));
    for k = 1:numel(v0_list)
        pj.theta = solve_release_angle(v0_list(k), pj);
        out = simulate_flight(v0_list(k), pj);
        dev(k, j) = out.yb;   % m
    end
end

% Plot
cols = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.13 0.55 0.13; 0.49 0.18 0.56];
styles = {'-', '--', '-.', ':'};
labels = arrayfun(@(v) sprintf('%d m/s (%.0f km/h, %.0f mph)', v, v*3.6, v/0.44704), ...
    v0_list, 'UniformOutput', false);

fig = figure('Color', 'w', 'Position', [100 100 800 500]);
ax = axes(fig); hold(ax, 'on');
for k = 1:numel(v0_list)
    plot(ax, seam_deg, dev(k,:), 'LineWidth', 1.8, 'Color', cols(k,:), ...
        'LineStyle', styles{k}, 'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', cols(k,:));
end
yline(ax, 0, 'k-'); xline(ax, 0, 'k-');
xlabel(ax, 'Seam angle, \alpha (deg)'); ylabel(ax, 'Lateral deviation at bounce (m)');
title(ax, 'Swing vs seam angle (assumed sin(4\alpha) model)');
lgd = legend(ax, labels, 'Location', 'best');
grid(ax, 'on'); box(ax, 'on');
set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.2 0.2 0.2], 'FontSize', 12);
ax.Title.Color = 'k'; ax.XLabel.Color = 'k'; ax.YLabel.Color = 'k';
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');

% Table
fprintf('\nLateral deviation at bounce (m)\n%-12s', 'Seam (deg)');
hdr = arrayfun(@(v) sprintf('%d m/s', v), v0_list, 'UniformOutput', false);
fprintf('%-12s', hdr{:});
fprintf('\n');
for j = 1:numel(seam_deg)
    fprintf('%-12d', seam_deg(j));
    fprintf('%-12.3f', dev(:, j));
    fprintf('\n');
end
