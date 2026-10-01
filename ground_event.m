function [value, isterminal, direction] = ground_event(~, s)
% GROUND_EVENT  Stop ode45 when the ball reaches the ground (z = 0).
%   value      : quantity whose zero crossing is detected (height, m)
%   isterminal : 1 = stop integration at the event
%   direction  : -1 = only trigger when z is decreasing (ball falling)
value      = s(3);
isterminal = 1;
direction  = -1;
end
