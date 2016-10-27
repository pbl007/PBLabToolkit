%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "FindThePhase.m"                                  %
% Purpose: Receive start and end for a sinusoidal wave, and    % 
% return the phase of each data point in that interval.        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [finalVec, currentSize] = FindThePhase(deltaTime, Data)
currentSize = size(Data, 1);
finalVec = Data(:,1) ./ deltaTime * 2*pi(); % normalizing all data points to 2pi
end