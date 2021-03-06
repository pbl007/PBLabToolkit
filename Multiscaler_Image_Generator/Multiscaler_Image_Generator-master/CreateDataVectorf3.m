%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "CreateDataVectorf3.m"                            %
% Purpose: Reads the hex_data vector that was created          %
% by LSTDataRead.m and creates a photon table of that          %
% measurement. Only reads the time_patch == f3 data.           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [Final_Dataset] = CreateDataVectorf3(Raw_Data, Data_Channel_Num, Range)
%% Check input
if ((Data_Channel_Num ~= 1) && (Data_Channel_Num ~= 2) && (Data_Channel_Num ~= 6)) % Wrong input
    error('Data channel is incorrect. Can be only 1, 2 or 6 (START)');
end

%% Photon data allocation
switch Data_Channel_Num
    case 1
        helpstr = repmat('001', size(Raw_Data, 1), 1) == Raw_Data(:,62:64); % helpstr locates the rows in which the wanted data channel was read
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),2:60); % creates a vector only containing wanted data
        TAG_Bits = Data_Readings(:,1:16); % reads TAG bits data and converts it to decimal
        Sweep_Counter = bin2dec(Data_Readings(:,17:23)); % reads sweep counter data and converts it to decimal
        Time_of_Arrival_Before_Sweep_Correction = bin2dec(Data_Readings(:,24:59)); % reads timestamp data and converts it to decimal
    case 2
        helpstr = repmat('010', size(Raw_Data, 1), 1) == Raw_Data(:,62:64); % helpstr locates the rows in which the wanted data channel was read
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),2:60); % creates a vector only containing wanted data
        TAG_Bits = Data_Readings(:,1:16); % reads TAG bits data and converts it to decimal
        Sweep_Counter = bin2dec(Data_Readings(:,17:23)); % reads sweep counter data and converts it to decimal
        Time_of_Arrival_Before_Sweep_Correction = bin2dec(Data_Readings(:,24:59)); % reads timestamp data and converts it to decimal
    case 6
        helpstr = repmat('110', size(Raw_Data, 1), 1) == Raw_Data(:,62:64); % helpstr locates the rows in which the wanted data channel was read
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),2:60); % creates a vector only containing wanted data
        TAG_Bits = Data_Readings(:,1:16); % reads TAG bits data and converts it to decimal
        Sweep_Counter = bin2dec(Data_Readings(:,17:23)); % reads sweep counter data and converts it to decimal
        Time_of_Arrival_Before_Sweep_Correction = bin2dec(Data_Readings(:,24:59)); % reads timestamp data and converts it to decimal
end

%% Check if the data vector is empty
if isempty(Data_Readings)
    fprintf('Data channel number %d was empty. ', Data_Channel_Num);
    Final_Dataset = [];
    return;
end

%% Update time of arrival to include sweep counter
if ~isempty(Sweep_Counter(Sweep_Counter(:,1) > 1,1))
    Time_of_Arrival = Time_of_Arrival_Before_Sweep_Correction(:,1) + (Sweep_Counter(:,1) - 1) * Range;
else
    Time_of_Arrival = Time_of_Arrival_Before_Sweep_Correction;
end

%% Send out the data table
Time_of_Arrival = sort(Time_of_Arrival);
Data_Lost = base2dec(Raw_Data(:,1), 10);
if size(Data_Readings, 1) == 1
    cell_help = cell(1, 4);
    cell_help{1,1} = Time_of_Arrival; cell_help{1,2} = Sweep_Counter; cell_help{1,3} = TAG_Bits; cell_help{1,4} = Data_Lost;
    Final_Dataset = cell2table(cell_help, 'VariableNames', {'Time_of_Arrival' 'Sweep_Counter' 'TAG_Bits' 'Data_Lost'});
else
    Final_Dataset = table(Time_of_Arrival, Sweep_Counter, TAG_Bits, Data_Lost);
end

%% Add first row of zeros (signaling the first start event which is unrecorded)
cell_help = cell(1, 4);
cell_help(:,:) = {0};
Final_Dataset = [cell2table(cell_help, 'VariableNames', {'Time_of_Arrival' 'Sweep_Counter' 'TAG_Bits' 'Data_Lost'}); Final_Dataset];
end