function header = generateHeader(imageTags, numOfChannels)

% Get FPS of tiff
startTime = regexp(imageTags(1).ImageDescription, 'frameTimestamps_sec = ([\d.]+)', 'tokens');
startTime = str2num(startTime{1}{1});
endTime = regexp(imageTags(2).ImageDescription, 'frameTimestamps_sec = ([\d.]+)', 'tokens');
endTime = str2num(endTime{1}{1});
header.fps = 1 / (endTime - startTime);

% Get timestamps of frames
allCells = struct2cell(imageTags);
stringarr = squeeze(string(allCells(7, :, :)));
header.frameTimestamps_sec = str2double(extractBetween(stringarr, "frameTimestamps_sec = ", newline))';

% Get FOV parameters
header.xPixels = imageTags(1).Width;
header.yPixels = imageTags(1).Height;
end
