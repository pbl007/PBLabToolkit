%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "CreateDataVector1a.m"                            %
% Purpose: Reads the hex_data vector that was created          %
% by LSTDataRead.m and creates a photon table of that          %
% measurement. Only reads the time_patch == 1a data.           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [Final_Dataset] = CreateDataVector1a(Raw_Data, Data_Channel_Num, Range)
%% Check input
if ((Data_Channel_Num ~= 1) && (Data_Channel_Num ~= 2) && (Data_Channel_Num ~= 6)) % Wrong input
    error('Data slot of PMT is incorrect. Can be only 1, 2 or 6 (START)');
end

%% Photon data allocation

switch Data_Channel_Num
    case 1
        helpstr = repmat('001', size(Raw_Data, 1), 1) == Raw_Data(:,46:48); % helpstr locates the rows in which the desired data channel is found
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),1:44); % creates a vector only containing PMT data
        Sweep_Counter = bin2dec(Data_Readings(:,1:16)); % reads sweep counter data and converts it to decimal
        Time_of_Arrival_Before_Sweep_Correction = bin2dec(Data_Readings(:,17:44)); % reads timestamp data and converts it to decimal
    case 2
        helpstr = repmat('010', size(Raw_Data, 1), 1) == Raw_Data(:,46:48); % helpstr locates the rows in which the desired data channel is found
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),1:44); % creates a vector only containing PMT data
        Sweep_Counter = bin2dec(Data_Readings(:,1:16)); % reads sweep counter data and converts it to decimal
        Time_of_Arrival_Before_Sweep_Correction = bin2dec(Data_Readings(:,17:44)); % reads timestamp data and converts it to decimal
    case 6
        helpstr = repmat('110', size(Raw_Data, 1), 1) == Raw_Data(:,46:48); % helpstr locates the rows in which the desired data channel is found
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),1:44); % creates a vector only containing PMT data
        Sweep_Counter = bin2dec(Data_Readings(:,1:16)); % reads sweep counter data and converts it to decimal
        Time_of_Arrival_Before_Sweep_Correction = bin2dec(Data_Readings(:,17:44)); % reads timestamp data and converts it to decimal       
end

%% Update time of arrival to include sweep counter

Time_of_Arrival = Time_of_Arrival_Before_Sweep_Correction(:,1) + (Sweep_Counter(:,1) - 1) * Range;

%% Send out the data table
Data_Lost = zeros(size(Data_Readings, 1),1); % No data lost bit in this type of file
Final_Dataset = table(Time_of_Arrival, Sweep_Counter, Data_Lost);

end