function head = minorloss(K, V, g)
    % This function calculates te head loss from a loss coefficient, average
    % velocity, and acceleration of gravity
    head = K * V^2/(2*g);
end