%% Script purpose:
% Let the user choose the relevant files for analysis.
% Construct the list of file names and folders to be fed into
% run_pipleine.m.

%% Preps
addpath('/data/MatlabCode/ScanImage/SI2016bR0_2016-12-12_dd0af29383');

%% Loops over each file and loads it into memory
cd(foldername);
for idx = 1:length(files)
    [header,Aout,imgInfo] = scanimage.util.opentif(files(idx).name, 'channel',1);
    files(idx).filename = files(idx).name(1:end-4);
    squeezedData = squeeze(Aout);
    % save([files(idx).filename, '.mat'], 'squeezedData', '-v7.3');  %
    % Uncomment above line if you wish to work with .mat. In this case,
    % also comment the line below.
    files(idx).name = squeezedData;
end
