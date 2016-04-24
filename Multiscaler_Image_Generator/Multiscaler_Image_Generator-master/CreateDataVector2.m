%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "CreateDataVector2.m"                             %
% Purpose: Reads the hex_data vector that was created          %
% by LSTDataRead.m and creates a photon table of that          %
% measurement. Only reads the time_patch == 2 data.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [Final_Dataset] = CreateDataVector2(Raw_Data, Data_Channel_Num, Range)
%% Check input
if ((Data_Channel_Num ~= 1) && (Data_Channel_Num ~= 2) && (Data_Channel_Num ~= 6)) % Wrong input
    error('Data slot of PMT is incorrect. Can be only 1, 2 or 6 (START)');
end

%% Photon data allocation

switch Data_Channel_Num
    case 1
        helpstr = repmat('001', size(Raw_Data, 1), 1) == Raw_Data(:,46:48); % helpmat locates the rows in which PMT data was read
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),1:44); % creates a vector only containing PMT data
        Time_of_Arrival = bin2dec(Data_Readings(:,1:44)); % reads timestamp data and converts it to decimal
    case 2
        helpstr = repmat('010', size(Raw_Data, 1), 1) == Raw_Data(:,46:48); % helpmat locates the rows in which PMT data was read
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),1:44); % creates a vector only containing PMT data
        Time_of_Arrival = bin2dec(Data_Readings(:,1:44));
    case 6
        helpstr = repmat('110', size(Raw_Data, 1), 1) == Raw_Data(:,46:48); % helpmat locates the rows in which PMT data was read
        Data_Readings = Raw_Data((sum(helpstr, 2) == 3),1:44); % creates a vector only containing PMT data
        Time_of_Arrival = bin2dec(Data_Readings(:,1:44));        
end

%% Create the data table
Data_Lost = zeros(size(Data_Readings, 1),1);
if size(Data_Readings, 1) == 1
    cell_help = cell(1, 2);
    cell_help{1,1} = Time_of_Arrival; cell_help{1,2} = Data_Lost;
    Final_Dataset = cell2table(cell_help, 'VariableNames', {'Time_of_Arrival' 'Data_Lost'});
else
    Final_Dataset = table(Time_of_Arrival, Data_Lost);
end

%% Add first row of zeros (signaling the first start event which is unrecorded)
cell_help = cell(1, 2);
cell_help{1,1} = 0; cell_help{1,2} = 0;
Final_Dataset = [cell2table(cell_help, 'VariableNames', {'Time_of_Arrival', 'Data_Lost'}); Final_Dataset];
end