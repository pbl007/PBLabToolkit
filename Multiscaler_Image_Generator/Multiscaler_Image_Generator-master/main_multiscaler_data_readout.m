%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "main_multiscaler_data_readout.m"                 %
% Purpose: Main program that controls the data readout from    %
% multiscaler list files. Run it to open the GUI to choose the %
% proper file or folder for readout.                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
close all;
clear all;
clc;

%% Open GUI
useIteration = 0; % One file or more?
numOfFiles = 'All files'; % Default choice
H = Multiscaler_GUI; % Start GUI
waitfor(H); % While GUI is open don't continue

%% Number of files to read
if useIteration 
    myFolderInfo = dir(folderOfFiles);
    myFolderCell = struct2cell(myFolderInfo); % Only names of files
    helpcell = strfind(myFolderCell(1,:), '.lst');
    listOfListFiles = myFolderCell(1,cellfun(@numel, helpcell) == 1); % Only files that end with .lst
    indexInListFile = 1; % Default is to start from first list file
    FileName = listOfListFiles{1,indexInListFile}
    
    %% Decide on the number of iterations
    if strcmp(numOfFiles, 'All files')
        numOfFiles_int = 1;
    else    
        numOfFiles_int = str2double(numOfFiles);
    end
else
    numOfFiles_int = 1;
end

currentIterationNum = 1;

while (currentIterationNum <= numOfFiles_int)
    %% Data Read
    fprintf('Reading file... ');
    [Binary_Data, Time_Patch, Range] = LSTDataRead(FileName);
    fprintf('File read successfully. Time patch value is %s. \nCreating data vectors... ', Time_Patch);

    %% Time patch choice - create data vector
    switch Time_Patch
        case '32'
            STOP1_Dataset   = CreateDataVector32(Binary_Data, 1, double(Range));
            STOP2_Dataset   = CreateDataVector32(Binary_Data, 2, double(Range));
            START_Dataset   = CreateDataVector32(Binary_Data, 6, double(Range));

        case '1a'
            STOP1_Dataset   = CreateDataVector1a(Binary_Data, 1, double(Range));
            STOP2_Dataset   = CreateDataVector1a(Binary_Data, 2, double(Range));
            START_Dataset   = CreateDataVector1a(Binary_Data, 6, double(Range)); 

        case '43'
            STOP1_Dataset   = CreateDataVector43(Binary_Data, 1, double(Range));
            STOP2_Dataset   = CreateDataVector43(Binary_Data, 2, double(Range));
            START_Dataset   = CreateDataVector43(Binary_Data, 6, double(Range));

        case '2'
            STOP1_Dataset   = CreateDataVector2(Binary_Data, 1, double(Range));
            STOP2_Dataset   = CreateDataVector2(Binary_Data, 2, double(Range));
            START_Dataset   = CreateDataVector2(Binary_Data, 6, double(Range));
    end
    fprintf('Data vectors created successfully. \nGenerating image...\n');
   

%% Create the photon cell array of lines

%CoordinateDeterminer;
[PhotonCellArray, NumOfLines, StartOfFrameChannel, MaxNumOfEventsInLine] = PhotonCells(START_Dataset, STOP1_Dataset, STOP2_Dataset, 1);
fprintf('Finished creating the photon cell array. Creating Raw image...\n');

%% Determine which data channel contains frame data
switch StartOfFrameChannel
    case 1
        StartOfFrameVector = STOP1_Dataset.Time_of_Arrival;
    case 2
        StartOfFrameVector = STOP2_Dataset.Time_of_Arrival;
    case 6
        StartOfFrameVector = START_Dataset.Time_of_Arrival;
end

%% Create Images 
SizeX = 1500;
SizeY = 150;

% Initialization before while loop
CurrentFramePhotons = cell(1, max(SizeX, SizeY)); % Initializing cell array for speed of execution
CurrentLineIndex = 1;
CurrentLineTime = PhotonCellArray{1, CurrentLineIndex};

for NumberOfFrame = 1:size(StartOfFrameVector, 1) - 1 % Runs over the amount of frames in the image, every image creates a new figure
    figure(NumberOfFrame);
    CurrentLineTime = PhotonCellArray{1, 2};
    NextFrameTime = StartOfFrameVector(NumberOfFrame + 1, 1); % Upper limit on the frame time
    while CurrentLineTime < NextFrameTime
        CurrentFramePhotons{CurrentLineIndex} = PhotonCellArray{2, CurrentLineIndex};
        CurrentLineIndex = CurrentLineIndex + 1;
        CurrentLineTime = PhotonCellArray{1, CurrentLineIndex};
    end
    [RawImage, C] = PhotonSpreadToImage2(cell2mat(CurrentFramePhotons), SizeX, SizeY, NumOfLines);
    CurrentFramePhotons = cell(1, max(SizeX, SizeY)); % Initialize data
end
%% Save Results

% MySaver;

%% Display Outcome

DisplayOutcome;

    %% Update while loop parameters
    if useIteration
        if strcmp(numOfFiles, 'All files')
            indexInListFile = indexInListFile + 1;
            helpcell = strfind(myFolderCell(1,:), '.lst'); % Update list of files in folder
            listOfListFiles = myFolderCell(1,cellfun(@numel, helpcell) == 1); % Only files that end with .lst
            FileName = listOfListFiles{1,indexInListFile}; % Move forward one file
        else
            currentIterationNum = currentIterationNum + 1;
            indexInListFile = indexInListFile + 1;
            helpcell = strfind(myFolderCell(1,:), '.lst'); % Update list of files in folder
            listOfListFiles = myFolderCell(1,cellfun(@numel, helpcell) == 1); % Only files that end with .lst
            FileName = listOfListFiles{1,indexInListFile}; % Move forward one file
        end
             
    else
        break; % When a specific file was chosen run the loop once
    end
end
