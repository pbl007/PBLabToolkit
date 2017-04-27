%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "DataHeaders.m"                                   %
% Purpose: Creates the right column of the event array. This   %
% column should contain the starting time bin number for the   %
% data that follows to the left of it.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [CellArrayFirstRow] = DataHeaders(Num_of_Lines, Data)
  
%% Create the first row of PhotonCellArray that holds the starting arrival time of this column
  CellArrayFirstRow = cell(1, Num_of_Lines);          
  StartingTimeOfLine = zeros(1, Num_of_Lines);
  StartingTimeOfLine(1,1:2:end) = table2array(Data(:,1))'; % odd cells receive the original numbers
  HalfDiffVector = round(diff(Data.Time_of_Arrival(:)) ./ 2);
  StartingTimeOfLine(1,2:2:end) = Data.Time_of_Arrival(1:end - 1) + HalfDiffVector; % even cells receive half of that number
  CellArrayFirstRow(1,:) = num2cell(StartingTimeOfLine); % first row of cell array is the starting arrival time (in time bins) of photons in that cell

end