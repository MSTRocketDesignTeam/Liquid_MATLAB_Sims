function deltap = hloss2pdrop(major, minor, deltaz, density, g)
    % This function calculates the pressure drop across a pipe given the
    % total change in head, the density, and the acceleration of gravity
    deltap = (major + minor - deltaz) * density * g;
end