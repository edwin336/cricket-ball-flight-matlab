%% SANITY_CHECK_VACUUM  With C_D = C_S = 0 the ball must follow the analytical projectile solution.
% Analytical: x = vx0*t, y = 0, z = z0 + vz0*t - g*t^2/2,
% flight time = positive root of z(t) = 0.
% Also checks specific energy E = v^2/2 + g*z is conserved.
% Fill in the parameter block (same values as cricket_ball_flight.m) before running.
clear; clc;

p.m = 0.160;  p.d = 0.072;  p.rho = 1.225;   % same as main script
p.theta = deg2rad(6);                        % fixed test angle (rad), no solver needed
p.z0 = 2.2;  p.g = 9.81;
p.A  = pi*(p.d/2)^2;
p.CD = 0;  p.CS_fun = @(v) 0;                % forces off

v0 = 35;                                  % m/s, any speed will do
out = simulate_flight(v0, p);

% Analytical solution
vx0 = v0*cos(p.theta);  vz0 = -v0*sin(p.theta);
tb_an = (vz0 + sqrt(vz0^2 + 2*p.g*p.z0))/p.g;   % s (positive root of z(t) = 0)
xb_an = vx0*tb_an;                                % m

fprintf('Flight time : numeric %.6f s | analytic %.6f s | diff %.2e s\n', out.tb, tb_an, out.tb - tb_an);
fprintf('Bounce x    : numeric %.6f m | analytic %.6f m | diff %.2e m\n', out.xb, xb_an, out.xb - xb_an);
fprintf('Bounce y    : %.2e m (should be ~0)\n', out.yb);

% Trajectory-wide error
z_an = p.z0 + vz0*out.t - 0.5*p.g*out.t.^2;
fprintf('Max |z error| over trajectory: %.2e m\n', max(abs(out.s(:,3) - z_an)));

% Energy conservation (per unit mass)
E = 0.5*sum(out.s(:,4:6).^2, 2) + p.g*out.s(:,3);
fprintf('Max relative energy drift: %.2e\n', max(abs(E - E(1)))/E(1));

assert(abs(out.tb - tb_an) < 1e-6 && abs(out.xb - xb_an) < 1e-5, 'Vacuum check FAILED');
disp('Vacuum check passed.');
