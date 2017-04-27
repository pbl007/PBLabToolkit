function header = generateHeader(imageTags, numOfChannels)

% Get FPS of tiff
startTime = regexp(imageTags(1).ImageDescription, 'frameTimestamps_sec = ([\d.]+)', 'tokens');
startTime = str2num(startTime{1}{1});
endTime = regexp(imageTags(2).ImageDescription, 'frameTimestamps_sec = ([\d.]+)', 'tokens');
endTime = str2num(endTime{1}{1});
header.fps = 1 / (endTime - startTime);

% Get timestamps of frames
vecOfTimes = zeros(1, length(imageTags) / numOfChannels);
for idx = 1:length(imageTags)
   curTime =  regexp(imageTags(idx).ImageDescription, 'frameTimestamps_sec = ([\d.]+)', 'tokens');
   vecOfTimes(idx) = str2double(curTime{1}{1});
end
header.frameTimestamps_sec = vecOfTimes;

% Get FOV parameters
header.xPixels = imageTags(1).Width;
header.yPixels = imageTags(1).Height;
end
