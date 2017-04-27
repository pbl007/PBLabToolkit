function [ dataRow ] = getDataFromCurrentDir( currentDir ,animalID, dataRow)
% getDataFromCurrentDir - looks for the following files in current folder and populates a table based on the column names

%   We look here for the following files:
% Stimulus times: a mat file containing "Analog1" on its name.
% Running speed: a mat file containing "Analog2" on its name.
% Max projection: a tif file containing matching '*proj*.tif' (has "proj")
% EP analysis vars: a mat file containing the animalID on its name.
%       from this file we extract C_df, S_or, Coor, fps

% dataRow is an empty structure (a future row in the compiled database)

%%
warning OFF BACKTRACE %turns off displaying line #
%look for data
ptr2mat = dir([currentDir filesep '*' animalID '*.mat']);
%mat file name cannot contain "analog" on it's name
%%
valid = zeros(numel(ptr2mat),1)
for iFILE = 1 : numel(valid)
    if isempty(strfind(ptr2mat(iFILE).name,'Analog'))
        valid(iFILE) = 1;
    end
  
end

if sum(valid)>1
    error('Folder contains more that a single .mat file with appropiate name')
end

ptr2mat = ptr2mat(logical(valid));
%%
%get EP data
if isempty(ptr2mat)
    warning('No EP data here...')
else
    load(fullfile(currentDir,ptr2mat.name))
    dataRow.dataFileName = ptr2mat.name;
    dataRow.Coor = Coor;
    dataRow.S_or = S_or;
    dataRow.C_df = C_df;
    dataRow.Cn = Cn;
end
    
%get fps
if exist('fps','var')
    dataRow.fps = fps;
else
    warning('No fps (file per second) variable present')
end

% Get max projection image
dataRow.maxProjImg = dataRow.Cn;

% Get analog times
ptr2mat = dir([currentDir filesep '*analog.txt']);
analogFilename = [ptr2mat.folder, filesep, ptr2mat.name];
if isempty(ptr2mat)
    warning('No Analog1 data here...')
else
    stimAndSpeed = load(analogFilename);
    dataRow.speedVector = stimAndSpeed(:, 2);
    dataRow.stimVector = stimAndSpeed(:, 1);
end

warning ON BACKTRACE