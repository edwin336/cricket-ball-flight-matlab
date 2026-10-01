function CS_fun = build_CS_fun(seam_deg, wear)
% BUILD_CS_FUN  Side-force coefficient C_S(v) for a given seam angle and ball condition.
%   seam_deg : seam angle (deg), see seam_factor.m
%   wear     : ball condition, 0 = new, 1 = heavily scuffed (default 0)
%   C_S(v) = C_S_speed(v - shift) * seam_factor(seam_deg)
%
% C_S_speed for a NEW ball: piecewise linear in speed, clamped outside the knots.
%   25-32 m/s: +0.3 (conventional swing); 32-36: taper to 0; 36-40: down to -0.2 (reverse swing)
% Calibrated at the 20 deg reference seam angle.
%
% ASSUMED ball-condition model: wear shifts every knot down in speed by
% wear * max_shift, so a scuffed ball has its swing window at lower speed and goes
% into reverse swing earlier. Direction matches the qualitative literature (old, rough
% balls reverse at lower speed, e.g. Sayers 2001, Mehta 2005) but max_shift is a guess.
if nargin < 2, wear = 0; end
max_shift = 8;                         % m/s shift at wear = 1 (assumption)
shift = wear * max_shift;              % m/s

cs_v = [25  32  36   40] - shift;      % knot speeds (m/s)
cs_c = [0.3 0.3 0   -0.2];             % C_S at knots (-)
seam = seam_factor(seam_deg, 20);      % (-), 1 at 20 deg
CS_fun = @(v) seam * interp1(cs_v, cs_c, min(max(v, cs_v(1)), cs_v(end)));
end
