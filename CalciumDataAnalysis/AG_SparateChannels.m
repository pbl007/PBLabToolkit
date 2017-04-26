%% Script purpose:
% Let the user choose the relevant files for analysis.
% Construct the list of file names and folders to be fed into
% run_pipleine.m.

%% Preps
addpath('/data/MatlabCode/ScanImage/SI2016bR0_2016-12-12_dd0af29383');
addpath('/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction/utilities/');
addpath('/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction/utilities/memmap');

%% Loops over each file and loads it into memory

for idx = 1:length(files)
    [header,Aout,imgInfo] = scanimage.util.opentif(files(idx).name, 'channel',1);
    files(idx).filename = files(idx).name(1:end-4);
    squeezedData = squeeze(Aout);
    % save([foldername, filesep, files(idx).filename, '.mat'], 'squeezedData', '-v7.3');  %
    % Uncomment above line if you wish to work with .mat. In this case,
    % also comment the line below.
    files(idx).name = squeezedData;
end

%% Delete files that prevent run_pipeline.m from working
filesToDel = subdir(fullfile(foldername,'*_nr.h5'));
filesToDel = [filesToDel; subdir(fullfile(foldername,'*_rig.h5'))];
filesToDel = [filesToDel; subdir(fullfile(foldername,'*_rig.mat'))];

for idx = 1:length(filesToDel)
    delete(filesToDel.name);
end