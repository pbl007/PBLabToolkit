function width = calcFWHM(data,smoothing,threshold)
% function which takes data and calculates the full-width, half max value
% half-max values are found looking in from the sides, i.e., the program will work
% even if the data dips to a lower value in the middle

if useGPU
    data = gpuArray( double(data));
else
    data=double(data);
end

% smooth data, if appropriate
if nargin < 2
    % smoothing not passed in, set to default (none)
    smoothing = 1;
end

if smoothing > 1
    data = conv(data,rectwin(smoothing) ./ smoothing);
end

% subtract out baseline
data = data - min(data);

if nargin < 3
    threshold = max(data)/2;
end

aboveI = find(data > threshold);    % all the indices where the data is above half max

if isempty(aboveI)
    % nothing was above threshold!
    width = 0;
    return
end

firstI = aboveI(1);                 % index of the first point above threshold
lastI = aboveI(end);                % index of the last point above threshold

if (firstI-1 < 1) | (lastI+1) > length(data)
    % interpolation would result in error, set width to zero and just return ...
    width = 0;
    return
end

% use linear intepolation to get a more accurate picture of where the max was
% find value difference between the point and the threshold value,
% and scale this by the difference between integer points ...
point1offset = (threshold-data(firstI-1)) / (data(firstI)-data(firstI-1));
point2offset = (threshold-data(lastI)) / (data(lastI+1)-data(lastI));

point1 = firstI-1 + point1offset;
point2 = lastI + point2offset;

width = point2-point1;
