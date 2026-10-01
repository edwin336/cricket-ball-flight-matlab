function dsdt = ball_ode(~, s, p)
% BALL_ODE  Right-hand side of the cricket ball equations of motion.
%   s    = [x; y; z; vx; vy; vz]   position (m) and velocity (m/s)
%   p    = parameter struct from cricket_ball_flight.m
%   dsdt = [vx; vy; vz; ax; ay; az]  (m/s, m/s^2)
%
% Coordinates: x down the pitch, y lateral (off side +), z up.

vel = s(4:6);                 % velocity vector (m/s)
v   = norm(vel);              % speed (m/s)

q = 0.5*p.rho*v^2*p.A;        % dynamic pressure x area (N per unit coefficient)

% Drag: magnitude q*C_D, direction opposite to velocity (-vel/v)
F_drag = -q*p.CD * vel/v;     % N, 3x1

% Swing: magnitude q*C_S, direction perpendicular to velocity in the horizontal plane.
% Unit vector (-vy, vx, 0)/|v_h|: dot product with vel is zero, so it does no work.
% With vy = 0 and vx > 0 it points +y (off side) when C_S > 0.
vh = hypot(vel(1), vel(2));                 % horizontal speed (m/s)
n_swing = [-vel(2); vel(1); 0] / vh;        % unit vector (-)
C_S = p.CS_fun(v);                          % side-force coefficient at INSTANTANEOUS speed (-)
F_swing = q*C_S * n_swing;                  % N, 3x1

% Gravity acts on z only
F_grav = [0; 0; -p.m*p.g];                  % N, 3x1

acc = (F_drag + F_swing + F_grav) / p.m;    % m/s^2, 3x1

dsdt = [vel; acc];
end
