function showFOS(name, strength, stress, varargin)
%SHOWFOS - Displays the factor of safety of a given setup
%   name - Display text to explain stress & FOS
%   strength - Material strength
%   stress   - Stress on material
%   unit (optional) - Unit to display (defaults to MPa)

unit = 'MPa';
if nargin > 3
    unit = varargin{1};
end

fprintf('%-25s \tStress: %3.1f %s \tFOS: %3.2f\n', name, stress, unit, strength./stress);
end