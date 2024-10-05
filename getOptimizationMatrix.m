function outp = getOptimizationMatrix(names, ranges, samples)
%GETOPTIMIZATIONMATRIX - Returns a set of named matrices that can be used
%for optimization analyses like the getAltitude function.
%
% This function generates an n-dimensional matrix where n is the number of
% rows in the ranges vector. It generates matrices such that each one
% varies in only one axis - i.e. each dimension corresponds to a varible
% with some meaning. This would allow you to run samples^n simulations at
% once without needing to iterate through all of the possibilities.
%
% names - Names of each set of variables
% ranges - n x 2 matrix where the first and second elements of each row is
% the range that is correlated with the corresponding value in the names
% field.
% samples - The number of samples to be taken between the range endpoints
% for each set of values.
%
% Warning: these output matrices can get really big really fast. A fairly
% reasonable value for matrix elements seems to be around 5,000,000, but
% this depends a lot on how complicated of a sim you're working with.
%

    d = size(ranges);
    n = d(1);

    if d(2) ~= 2
        error('Please input ranges with two values');
    end

    for i = 1:n
        line = linspace(ranges(i,1), ranges(i,2), samples);
        
        shapeVec = (1:n == i)*(samples-1) + 1;
        line = reshape(line, shapeVec);

        space = line.*ones(ones(1,n)*(samples));

        outp.(names(i)) = space;
    end
end