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
    FileName = listOfListFiles{1,indexInListFile};
    
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
            PMT_Dataset   = CreateDataVector32(Binary_Data, 1, double(Range));
            Galvo_Dataset = CreateDataVector32(Binary_Data, 2, double(Range));
            TAG_Dataset   = CreateDataVector32(Binary_Data, 6, double(Range));

        case '1a'
            PMT_Dataset   = CreateDataVector1a(Binary_Data, 1, double(Range));
            Galvo_Dataset = CreateDataVector1a(Binary_Data, 2, double(Range));
            TAG_Dataset   = CreateDataVector1a(Binary_Data, 6, double(Range)); 

        case '43'
            PMT_Dataset   = CreateDataVector43(Binary_Data, 1, double(Range));
            Galvo_Dataset = CreateDataVector43(Binary_Data, 2, double(Range));
            TAG_Dataset   = CreateDataVector43(Binary_Data, 6, double(Range));

        case '2'
            PMT_Dataset   = CreateDataVector2(Binary_Data, 1, double(Range));
            Galvo_Dataset = CreateDataVector2(Binary_Data, 2, double(Range));
            TAG_Dataset   = CreateDataVector2(Binary_Data, 6, double(Range));
    end
    fprintf('Data vectors created successfully. \nGenerating image...\n');
    %% Blubber

    TotalHitsX = [];
    TotalHitsZ = [];


    for SweepNumber = 1:100

        photon_single_sweep = PMT_Dataset((PMT_Dataset.Sweep_Counter == SweepNumber),1);
        Galvo_single_sweep = Galvo_Dataset((Galvo_Dataset.Sweep_Counter == SweepNumber),1);
        TAG_single_sweep = TAG_Dataset((TAG_Dataset.Sweep_Counter == SweepNumber),1);


        % MaximalGalvoPeriod = max(diff(table2array(Galvo_single_sweep)));
        % 
        % [G,P] = meshgrid(single(table2array(Galvo_single_sweep)),single(table2array(photon_single_sweep)));
        % 
        % RawRelativePhotonArrivalTime = P-G;
        % RawRelativePhotonArrivalTime(RawRelativePhotonArrivalTime < 1) = 1e10;
        % RawRelativePhotonArrivalTime(RawRelativePhotonArrivalTime > MaximalGalvoPeriod) = 1e10;
        % 
        % RelativePhotonArrivalTime = min(RawRelativePhotonArrivalTime');
        % RelativePhotonArrivalTime(RelativePhotonArrivalTime>1e9) = 1;

        X_hits = ArrivalTimeRelativer(Galvo_single_sweep,photon_single_sweep);
        Z_hits = ArrivalTimeRelativer(TAG_single_sweep,photon_single_sweep);

        TotalHitsX = [TotalHitsX; X_hits];
        TotalHitsZ = [TotalHitsZ; Z_hits];

    end


%% Determine Coordinates

CoordinateDeterminer;

%% Create Image 

PhotonSpreadToImage;

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
