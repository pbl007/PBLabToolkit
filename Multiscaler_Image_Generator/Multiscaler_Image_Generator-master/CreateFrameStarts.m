
%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "CreateFrameStarts.m"                             %
% Purpose: Creates a vector containing all start-of-frame      %
% signals (after doubling them).                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function StartOfFrameVec = CreateFrameStarts(DataFrames)

%% Create basic vector of start-of-frame times
StartOfFrameVec = zeros(1, size(DataFrames, 1) * 2 - 1);
StartOfFrameVec(1,1:2:end) = (DataFrames(:,1))'; % odd cells receive the original numbers
HalfDiffVector = round(diff(DataFrames(:)) ./ 2);
StartOfFrameVec(1,2:2:end) = DataFrames(1:end - 1) + HalfDiffVector;
StartOfFrameVec = (StartOfFrameVec)';

end
