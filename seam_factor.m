function f = seam_factor(seam_deg, ref_deg)
% SEAM_FACTOR  Dimensionless scaling of the side-force coefficient with seam angle.
%   seam_deg : seam angle to the flow direction (deg); sign sets swing direction
%   ref_deg  : angle at which the factor is exactly 1 (deg), where C_S was calibrated
%
% ASSUMED model (not from the literature): f = sin(4*alpha)/sin(4*alpha_ref), alpha clamped to +/-45 deg.
%   alpha = 0   -> f = 0     no seam asymmetry, no swing
%   alpha ~ 22.5 -> f peaks  (~1.015 at ref 20 deg)
%   alpha = 45  -> f = 0     both boundary layers trip, asymmetry lost
%   alpha < 0   -> f < 0     seam tilted the other way, swing reverses direction
% The shape is chosen to match the qualitative behaviour reported in wind-tunnel work
% (peak side force at a moderate seam angle, none at 0). Check the exact angle and shape
% against Mehta (1985) and Sayers & Hill (1999) before quoting it.
a = min(max(deg2rad(seam_deg), -pi/4), pi/4);   % rad, clamped
f = sin(4*a) / sin(4*deg2rad(ref_deg));         % (-)
end
