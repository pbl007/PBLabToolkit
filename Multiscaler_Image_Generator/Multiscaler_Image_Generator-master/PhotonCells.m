%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "PhotonCells.m"                                   %
% Purpose: Devides received data points into a two-columned    %
% array. First one is the photon arrival time relative to the  %
% second column, which is the start-of-row time.               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [PhotonArray, Num_of_Lines, StartOfFramesChannel, MaxNumOfEventsInLine, TotalEvents, PMTChannelNum, MaxDiffOfLines] = PhotonCells(START_Dataset, STOP1_Dataset, STOP2_Dataset, PMT_Channel_Num)

PMTChannelNum = PMT_Channel_Num;
% The switch determines which channel contains the photon arrival time data. 
switch PMT_Channel_Num
    case 1
        TotalEvents = size(STOP1_Dataset.Time_of_Arrival,1);
        if (isempty(START_Dataset) && isempty(STOP2_Dataset))
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, 0, STOP1_Dataset, []);
            Num_of_Lines = 0;
            StartOfFramesChannel = 0;
            MaxNumOfEventsInLine = 0;
        elseif isempty(START_Dataset)
            Num_of_Lines = numel(STOP2_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            StartOfFramesChannel = 0; % Since STOP2_Dataset contains line data, START contains frame data

            %% Create the final cell array
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP1_Dataset, STOP2_Dataset);
        elseif isempty(STOP2_Dataset)
            Num_of_Lines = numel(START_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            StartOfFramesChannel = 0; % Since START_Dataset contains line data, STOP2 contains frame data

            %% Create the final array
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP1_Dataset, START_Dataset);
        elseif (~isempty(START_Dataset) && (~isempty(STOP2_Dataset)))
            mean_frequency_start = mean(diff(START_Dataset.Time_of_Arrival(1:end))); % here we find the data channel that is responsible to the rows of the picture.
            mean_frequency_stop2 = mean(diff(STOP2_Dataset.Time_of_Arrival(1:end)));
            if mean_frequency_start < mean_frequency_stop2 
                Num_of_Lines = numel(START_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
                StartOfFramesChannel = 2; % Since START_Dataset contains line data, STOP2 contains frame data

                %% Create the final array
                [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP1_Dataset, START_Dataset);

            else
                Num_of_Lines = numel(STOP2_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
                StartOfFramesChannel = 6; % Since STOP2_Dataset contains line data, START contains frame data

                %% Create the final cell array
                [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP1_Dataset, STOP2_Dataset);
            end
        end
        
    case 2
        TotalEvents = size(STOP2_Dataset.Time_of_Arrival,1);
        if (isempty(START_Dataset) && isempty(STOP1_Dataset))
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, 0, STOP2_Dataset, []);
            Num_of_Lines = 0;
            StartOfFramesChannel = 0;
            MaxNumOfEventsInLine = 0;
        elseif isempty(START_Dataset)
            Num_of_Lines = numel(STOP1_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            StartOfFramesChannel = 0; % Since STOP2_Dataset contains line data, START contains frame data

            %% Create the final cell array
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP2_Dataset, STOP1_Dataset);
        elseif isempty(STOP1_Dataset)
            Num_of_Lines = numel(START_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            StartOfFramesChannel = 0; % Since STOP2_Dataset contains line data, START contains frame data
            
            %% Create the final cell array
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP2_Dataset, START_Dataset);
        
        elseif (~isempty(START_Dataset) && (~isempty(STOP1_Dataset)))     
            mean_frequency_start = mean(diff(START_Dataset.Time_of_Arrival(1:100)));
            mean_frequency_stop1 = mean(diff(STOP1_Dataset.Time_of_Arrival(1:100)));
            if mean_frequency_start < mean_frequency_stop1
                Num_of_Lines = numel(START_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
                StartOfFramesChannel = 1; % Since START_Dataset contains line data, STOP1 contains frame data

                %% Create the final cell array
                [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP2_Dataset, START_Dataset);

            else
                Num_of_Lines = numel(STOP1_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
                StartOfFramesChannel = 2; % Since STOP1_Dataset contains line data, START contains frame data

                %% Create the final cell array
                [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, STOP2_Dataset, STOP1_Dataset);
            end
        end
    case 6
        TotalEvents = size(START_Dataset.Time_of_Arrival,1);
        if (isempty(STOP1_Dataset) && isempty(STOP2_Dataset))
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, 0, START_Dataset, []);
            Num_of_Lines = 0;
            StartOfFramesChannel = 0;
            MaxNumOfEventsInLine = 0;
        elseif isempty(STOP1_Dataset)
            Num_of_Lines = numel(STOP2_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            StartOfFramesChannel = 0; % Since STOP2_Dataset contains line data, START contains frame data

            %% Create the final cell array
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, START_Dataset, STOP2_Dataset);
        elseif isempty(STOP2_Dataset)
            Num_of_Lines = numel(STOP1_Dataset.Time_of_Arrival) .* 2 - 1;
            StartOfFramesChannel = 0; % Since STOP2_Dataset contains line data, START contains frame data
            
            %% Create the final cell array
            [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, START_Dataset, STOP1_Dataset);
        elseif (~isempty(STOP1_Dataset) && (~isempty(STOP2_Dataset)))     
            mean_frequency_stop1 = mean(diff(STOP1_Dataset.Time_of_Arrival(1:100)));
            mean_frequency_stop2 = mean(diff(STOP2_Dataset.Time_of_Arrival(1:100)));
            if mean_frequency_stop2 < mean_frequency_stop1
                Num_of_Lines = numel(STOP2_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
                StartOfFramesChannel = 1; % Since STOP2_Dataset contains line data, STOP1 contains frame data

                %% Create the final cell array
                [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, START_Dataset, STOP2_Dataset);

            else
                Num_of_Lines = numel(STOP1_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
                StartOfFramesChannel = 2; % Since STOP1_Dataset contains line data, STOP2 contains frame data

                %% Create the final cell array
                [PhotonArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(TotalEvents, Num_of_Lines, START_Dataset, STOP1_Dataset);
            end 
        end
end

end