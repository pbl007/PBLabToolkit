%% Script purpose:
% Let the user choose the relevant files for analysis.
% Construct the list of file names and folders to be fed into
% run_pipleine.m.

%% Preps
addpath('/data/MatlabCode/ScanImage/SI2016bR0_2016-12-12_dd0af29383');
addpath('/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction/utilities/');
addpath('/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction/utilities/memmap');
addpath('/data/MatlabCode/PBLabToolkit/External/TIFFStack');

%% Loops over each file and loads it into memory
header = struct('fps', [], 'frameTimestamps_sec', [], ...
                'xPixels', [], 'yPixels', []);

for idx = 1:length(files)
    curStack = TIFFStack(files(idx).name, [], [numOfChannels 1]);
    Aout = squeeze(curStack(:, :, 1, 1, :));  % channel 1
    files(idx).filename = files(idx).name(1:end-4);
    % save([foldername, filesep, files(idx).filename, '.mat'], 'Aout', '-v7.3');  %
    % Uncomment above line if you wish to work with .mat. In this case,
    % also comment the line below.
    files(idx).name = Aout;
    numOfFrames = size(Aout, 3);
    header(idx) = generateHeader(getImageTags(curStack, 1:numOfChannels:(numOfFrames * numOfChannels)), numOfChannels);
end

%% Delete files that prevent run_pipeline.m from working
filesToDel = subdir(fullfile(foldername,'*_nr.h5'));
filesToDel = [filesToDel; subdir(fullfile(foldername,'*_rig.h5'))];
filesToDel = [filesToDel; subdir(fullfile(foldername,'*_rig.mat'))];

for idx = 1:length(filesToDel)
    delete(filesToDel.name);
end