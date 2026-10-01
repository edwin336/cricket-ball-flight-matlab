function theta = solve_release_angle(v0, p)
% SOLVE_RELEASE_ANGLE  Shooting method: find the downward release angle (rad)
% so the ball first bounces at x = p.x_bounce, drag and swing included.
%   Root-finds f(theta) = x_bounce(theta) - p.x_bounce with fzero (base MATLAB).
%   Bracket: 0.5 deg (bounces far down the pitch) to 20 deg (bounces short).
f = @(th) bounce_error(th, v0, p);
theta = fzero(f, [deg2rad(0.5) deg2rad(20)]);
end

function err = bounce_error(th, v0, p)
p.theta = th;
out = simulate_flight(v0, p);
err = out.xb - p.x_bounce;   % m
end
