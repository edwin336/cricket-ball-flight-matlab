function out = simulate_flight(v0, p)
% SIMULATE_FLIGHT  Integrate one delivery from release to first bounce.
%   v0  : release speed (m/s)
%   p   : parameter struct (see cricket_ball_flight.m)
%   out : struct with t (s), s (N x 6 state history), tb (flight time, s),
%         xb, yb (bounce position, m)

% Initial velocity: release angle is measured below the horizontal, no lateral component
vx0 = v0*cos(p.theta);   % m/s
vz0 = -v0*sin(p.theta);  % m/s
s0  = [0; 0; p.z0; vx0; 0; vz0];

opts = odeset('Events', @ground_event, 'RelTol', 1e-8, 'AbsTol', 1e-10);
[t, s, te, se] = ode45(@(t, s) ball_ode(t, s, p), [0 5], s0, opts);

assert(~isempty(te), 'Ball never reached z = 0 within 5 s - check release angle/parameters.');

out.t  = t;
out.s  = s;
out.tb = te(end);       % s
out.xb = se(end, 1);    % m
out.yb = se(end, 2);    % m
end
