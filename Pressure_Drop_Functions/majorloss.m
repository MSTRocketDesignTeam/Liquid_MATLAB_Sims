function head = majorloss(ff, L, ID, V, g)
% This function calculates the major loss from friction in a pipe. The
% variables considered are friction factor, pipe length, inner diameter,
% average velocity, and acceleration of gravity
head = ff * L/ID * V^2/(2*g);
end