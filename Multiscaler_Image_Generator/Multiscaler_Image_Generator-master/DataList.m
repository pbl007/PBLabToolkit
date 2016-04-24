%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "DataList.m"                                      %
% Purpose: Creates the list of events for every time bin. For  %
% example, for the time bin that starts after 200 time units   %
% the output should be an array of the arrival times of        %
% photons that came after 200 time bins (relative to 200), but %
% before the next time bin. The script also flips the even     %
% cells and deletes empty columns to save memory.              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [DataCellArray] = DataList(Num_of_Events, Num_of_Lines, Data, DataStarts)

DataCellArray = cell(2, Num_of_Lines);
DataCellArray(1, :) = DataStarts;

%% Create the second row, that contains a list of photon arrival times
CurrentDataValue = Data.Time_of_Arrival(1);
CurrentDataNumber = 1;
CurrentDataArray = zeros(Num_of_Events,1);
for CurrentLine = 1:Num_of_Lines - 1
    while ((CurrentDataValue < DataStarts{1,CurrentLine + 1}) && (CurrentDataNumber <= Num_of_Events))
        CurrentDataArray(CurrentDataNumber, 1) = CurrentDataValue;
        CurrentDataNumber = CurrentDataNumber + 1;
        CurrentDataValue = Data.Time_of_Arrival(CurrentDataNumber);
    end
    DataCellArray{2,CurrentLine} = CurrentDataArray(CurrentDataArray > 0);
    CurrentDataArray = [];
end
        
%% Flip the even cells for image generation
DataCellArray(2,2:2:end) = cellfun(@flip, DataCellArray(2, 2:2:end), 'UniformOutput', false);
        
%% Remove empty cells
DataCellArray(:,cellfun('isempty', DataCellArray(2,:))) = [];
        
%% Substract the time bin headline of all photons in that bin
DataCellArray(2,:) = cellfun(@minus, DataCellArray(2,:), DataCellArray(1,:), 'UniformOutput', 0);
end