%% BALL_CONDITION_SWEEP  Lateral deviation at the bounce vs release speed for new/worn balls.
% Release angle re-solved at every point so every ball pitches at p.x_bounce.
clear; clc; close all;

p.m = 0.160;  p.d = 0.072;  p.rho = 1.225;  p.CD = 0.45;   % same as main script
p.A = pi*(p.d/2)^2;  p.g = 9.81;
p.z0 = 2.2;  p.x_stump = 18.9;  p.x_bounce = p.x_stump - 6.5;
seam_deg = 20;                        % seam angle (deg)

wear_list = [0 0.5 1];                % 0 = new, 1 = heavily scuffed
wear_names = {'New (wear 0)', 'Used (wear 0.5)', 'Scuffed (wear 1)'};
v0_list = 20:1:40;                    % m/s
dev = zeros(numel(wear_list), numel(v0_list));   % lateral deviation at bounce (m)

for i = 1:numel(wear_list)
    pi_ = p;
    pi_.CS_fun = build_CS_fun(seam_deg, wear_list(i));
    for k = 1:numel(v0_list)
        pi_.theta = solve_release_angle(v0_list(k), pi_);
        out = simulate_flight(v0_list(k), pi_);
        dev(i, k) = out.yb;   % m
    end
end

% Plot: x axis in m/s with km/h on the secondary label via title text
cols = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.49 0.18 0.56];
styles = {'-', '--', ':'};
fig = figure('Color', 'w', 'Position', [100 100 800 500]);
ax = axes(fig); hold(ax, 'on');
for i = 1:numel(wear_list)
    plot(ax, v0_list, dev(i,:), 'LineWidth', 1.8, 'Color', cols(i,:), 'LineStyle', styles{i}, ...
        'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', cols(i,:));
end
yline(ax, 0, 'k-');
xlabel(ax, 'Release speed (m/s)   [20 m/s = 72 km/h = 45 mph; 40 m/s = 144 km/h = 89 mph]');
ylabel(ax, 'Lateral deviation at bounce (m)');
title(ax, sprintf('Ball condition and swing, seam angle %d\\circ (assumed knot shift model)', seam_deg));
lgd = legend(ax, wear_names, 'Location', 'best');
grid(ax, 'on'); box(ax, 'on');
set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.2 0.2 0.2], 'FontSize', 12);
ax.Title.Color = 'k'; ax.XLabel.Color = 'k'; ax.YLabel.Color = 'k';
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');

% Table at the four headline speeds
sel = ismember(v0_list, [25 30 35 40]);
fprintf('\nLateral deviation at bounce (m), seam %d deg\n%-18s', seam_deg, 'Condition');
fprintf('%-10s', '25 m/s', '30 m/s', '35 m/s', '40 m/s'); fprintf('\n');
for i = 1:numel(wear_list)
    fprintf('%-18s', wear_names{i});
    fprintf('%-10.3f', dev(i, sel)); fprintf('\n');
end
