function showFOS(name, strength,stress)
%SHOWFOS - Displays the factor of safety of a given setup
%   name - Display text to explain stress & FOS

fprintf('%-25s \tStress: %3.1f MPa \tFOS: %3.2f', name, stress, strength/stress);
end