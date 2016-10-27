%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "CreateDataList.m"                                %
% Purpose: Creates a two-columned vector - left column is the  %
% photon arrival time (in timebins), and the right one is the  %
% fitting start-of-line time. It also flips the lines and      %
% frames so an image could be generated.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [DataArray, MaxNumOfEventsInLine, MaxDiffOfLines] = CreateDataList(Num_of_Events, Num_of_Lines, DataEvents, DataLines)

if Num_of_Lines == 0
    DataArray(:,1) = DataEvents.Time_of_Arrival(:);
    DataArray(:,2) = ones(size(DataArray, 1), 1);
    MaxNumOfEventsInLine = 0;
    return;
end

%% Create basic vector of start-of-line times
StartingTimeOfLine = zeros(1, Num_of_Lines);
StartingTimeOfLine(1,1:2:end) = table2array(DataLines(:,1))'; % odd cells receive the original numbers
HalfDiffVector = round(diff(DataLines.Time_of_Arrival(:)) ./ 2);
StartingTimeOfLine(1,2:2:end) = DataLines.Time_of_Arrival(1:end - 1) + HalfDiffVector; % even cells receive half of that number
MaxDiffOfLines = max(diff(StartingTimeOfLine(1, :)));

%% Create the full data vector
DataArray = NaN(Num_of_Events, 2); % Initialize the full data cell array
DataArray(:,1) = DataEvents.Time_of_Arrival(:);

CurrentDataValue = DataEvents.Time_of_Arrival(1);
CurrentDataNumber = 0;
NumOfEventsInLine = 0; % To receive the maximum number of photons in all line, for use when generating the image 
MaxNumOfEventsInLine = 0;
LastUsedLine = 0;

for CurrentLine = 1:Num_of_Lines - 1
    while ((CurrentDataValue < StartingTimeOfLine(1, CurrentLine + 1))  && (CurrentDataNumber + 1 <= Num_of_Events))
        DataArray(CurrentDataNumber + 1, 2) = StartingTimeOfLine(1, CurrentLine);
        
        % Next line of data follows:
        
        CurrentDataValue = DataEvents.Time_of_Arrival(CurrentDataNumber + 1);
        
        MaxNumOfEventsInLine = max(MaxNumOfEventsInLine, NumOfEventsInLine + 1);
        CurrentDataNumber = CurrentDataNumber + 1;
        NumOfEventsInLine = NumOfEventsInLine + 1;
      
    end
    %% Flip frames and lines
    
    %%
    LastUsedLine = LastUsedLine + NumOfEventsInLine;
    NumOfEventsInLine = 0;
end

%% Change the NaNs at the end of the DataArray
DataArray(isnan(DataArray)) = StartingTimeOfLine(1, end);

%% Substract the line time from photon arrival times to receive relative arrival times
DataArray(:,1) = DataArray(:,1) - DataArray(:,2);

%% 

end