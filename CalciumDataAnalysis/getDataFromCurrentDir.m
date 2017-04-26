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
elseif exist('FpS','var')
    dataRow.fps = FpS;
else
    warning('No fps (file per second) variable present')
end

%get max projection image
dataRow.maxProjImg = dataRow.Cn;
% ptr2tif = dir([currentDir filesep  '*proj*.tif']);
% 
% if isempty(ptr2tif)
%     warning('Missing max projection file containing "proj" on its filename :-(')
% else
%     img = imread(fullfile(currentDir,ptr2tif.name));
%     dataRow.maxProjImg = dataRow.Cn;
% end

%get  Stimulus times
ptr2mat = dir([currentDir filesep '*analog1*.mat']);

if isempty(ptr2mat)
    warning('No Analog1 data here...')
else
    load(fullfile(currentDir,ptr2mat.name))
    dataRow.StimVector = Ch3_analog.Ch3;
end

%get  running speed
ptr2mat = dir([currentDir filesep '*analog2*.mat']);

if isempty(ptr2mat)
    warning('No Analog2 data here...')
else
    load(fullfile(currentDir,ptr2mat.name))
    dataRow.SpeedVector = Ch4_analog.Ch4;
end

warning ON BACKTRACE