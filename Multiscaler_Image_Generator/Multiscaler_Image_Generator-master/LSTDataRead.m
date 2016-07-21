%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "LSTDataRead.m"                                   %
% Purpose: Receives a filename of a list file from the         %
% multiscaler and creates a binary string vector of that data. % 
% It also detects the time_patch and range value of the data.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [binary_data, time_patch, range] = LSTDataRead(FileName)

fileID = fopen(FileName);

%% Find the range value
formatSpec = 'range=%d';
range_cell = textscan(fileID, formatSpec, 'HeaderLines', 1);
range_before_bit_depth = cell2mat(range_cell);

%% Find the bit depth value
formatSpec = 'bitshift=%d';
bitshift_cell = textscan(fileID, formatSpec, 'HeaderLines', 32);
bitshift = mod(bitshift_cell{1,1}, 100);
range = range_before_bit_depth * 2^(bitshift);

%% Find the time_patch value
formatSpec = '%s';
expr = 'time_patch=(\w+)';
time_patch_cell = cell(0);
while isempty(time_patch_cell)
    current_line_cell = textscan(fileID, formatSpec, 1);
    [time_patch_cell] = regexp(cell2mat(current_line_cell{1,1}), expr, 'tokens');
end
time_patch = cell2mat(time_patch_cell{1,1});

%% Reach Data
formatSpec = '%s';
temp1 = {'[DATA]'}; % Start of DATA text line
temp2 = {'abc'}; % Initialization
while ~cellfun(@strcmp, temp1, temp2);
    temp2 = textscan(fileID, formatSpec, 1);
end

%% Read Data
hex_data = textscan(fileID, formatSpec);

%% Depending on time_patch number, read the data vector accordingly
keySet = {'32', '1a', '43', '2', '2a', '22', '5b', 'Db', 'f3', 'c3', '3'};
valueSet ={48, 48, 64, 48, 48, 48, 64, 64, 64, 64, 64}; 
% WHEN ADDING A NEW TIME PATCH DON'T FORGET TO UPDATE MAIN SCRIPT AND THE
% CREATE DATA VECOTR FUNCTION
mapObj = containers.Map(keySet, valueSet);

binary_data = hex2bin(hex_data{1,1}(:,1), mapObj(time_patch));

fclose(fileID);
end
