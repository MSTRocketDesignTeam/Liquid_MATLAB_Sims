function FOS = getFOS(stress, material, strengthMetric)
% if isEmpty(varargin)
%   temp = varargin{1};
% else
%   temp = 25; %   C   Material temperature
% end

mat = getMaterialProperties(material);
strength = mat.(strengthMetric);

FOS = strength/stress;
end