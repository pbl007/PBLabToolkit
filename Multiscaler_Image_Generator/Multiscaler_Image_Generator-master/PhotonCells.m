%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "PhotonCells.m"                                   %
% Purpose: Devides received data points into a cell array,     %
% each column having its timecode and list of events (with     %
% their time relative to the header).                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [PhotonCellArray, NumOfLines] = PhotonCells(START_Dataset, STOP1_Dataset, STOP2_Dataset, PMT_Channel_Num)

% The switch determines in which channel will we find the photon arrival time data. 
switch PMT_Channel_Num
    case 1
        mean_frequency_start = mean(diff(START_Dataset.Time_of_Arrival(1:end))); % here we find the data channel that is responsible to the rows of the picture.
        mean_frequency_stop2 = mean(diff(STOP2_Dataset.Time_of_Arrival(1:end)));
        if mean_frequency_start < mean_frequency_stop2 
            Num_of_Lines = numel(START_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            DataStarts = DataHeaders(Num_of_Lines, START_Dataset);
          
            %% Create the final cell array
            TotalEvents = size(STOP1_Dataset.Time_of_Arrival,1);
            PhotonCellArray = DataList(TotalEvents, Num_of_Lines, STOP1_Dataset, DataStarts);
            
        else
            Num_of_Lines = numel(STOP2_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            DataStarts = DataHeaders(Num_of_Lines, STOP2_Dataset);
            
            %% Create the final cell array
            TotalEvents = size(STOP1_Dataset.Time_of_Arrival,1);
            PhotonCellArray = DataList(TotalEvents, Num_of_Lines, STOP1_Dataset, DataStarts);
        end     
    case 2
        mean_frequency_start = mean(diff(START_Dataset.Time_of_Arrival(1:100)));
        mean_frequency_stop1 = mean(diff(STOP1_Dataset.Time_of_Arrival(1:100)));
        if mean_frequency_start < mean_frequency_stop1
            Num_of_Lines = numel(START_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            DataStarts = DataHeaders(Num_of_Lines, START_Dataset);
          
            %% Create the final cell array
            TotalEvents = size(STOP2_Dataset.Time_of_Arrival,1);
            PhotonCellArray = DataList(TotalEvents, Num_of_Lines, STOP2_Dataset, DataStarts);
            
        else
            Num_of_Lines = numel(STOP1_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            DataStarts = DataHeaders(Num_of_Lines, STOP1_Dataset);
            
            %% Create the final cell array
            TotalEvents = size(STOP2_Dataset.Time_of_Arrival,1);
            PhotonCellArray = DataList(TotalEvents, Num_of_Lines, STOP2_Dataset, DataStarts);
        end
    case 6
        mean_frequency_stop1 = mean(diff(STOP1_Dataset.Time_of_Arrival(1:100)));
        mean_frequency_stop2 = mean(diff(STOP2_Dataset.Time_of_Arrival(1:100)));
        if mean_frequency_stop2 < mean_frequency_stop1
            Num_of_Lines = numel(STOP2_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            DataStarts = DataHeaders(Num_of_Lines, STOP2_Dataset);
          
            %% Create the final cell array
            TotalEvents = size(START_Dataset.Time_of_Arrival,1);
            PhotonCellArray = DataList(TotalEvents, Num_of_Lines, START_Dataset, DataStarts);
            
        else
            Num_of_Lines = numel(STOP1_Dataset.Time_of_Arrival) .* 2 - 1; % Each start-of-line signal tells us that two lines have passed.
            DataStarts = DataHeaders(Num_of_Lines, STOP1_Dataset);
            
            %% Create the final cell array
            TotalEvents = size(START_Dataset.Time_of_Arrival,1);
            PhotonCellArray = DataList(TotalEvents, Num_of_Lines, START_Dataset, DataStarts);
        end 
end

end