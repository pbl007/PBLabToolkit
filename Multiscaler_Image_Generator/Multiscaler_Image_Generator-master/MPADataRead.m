%CSV File Readout
fileID = fopen('DATAAAATTATATATA.dat');
formatSpec = '%f %f';
All_Data = textscan(fileID, formatSpec, 'HeaderLines', 108, 'Delimiter', '\t'); 
Row_Data = horzcat(All_Data{1,1}, All_Data{1,2});
clear('All_Data');
All_Data = textscan(fileID, formatSpec, 'HeaderLines', 1, 'Delimiter', '\t');
Photon_Data = horzcat(All_Data{1,1}, All_Data{1,2});
clear('All_Data');
All_Data = textscan(fileID, formatSpec, 'HeaderLines', 1, 'Delimiter', '\t');
Frame_Data = horzcat(All_Data{1,1}, All_Data{1,2});

%Start of image matrix generation
general_index = 1; general_row = 1; cur_col = 1; f_index = 0; r_index = 0;
%Image1 = zeros(); %Use this line if size (in bins) of row is known

while f_index == 0
    while r_index == 0
        Image1(general_row, cur_col) = Photon_Data(general_index,2);
        general_index = general_index + 1;
        cur_col = cur_col + 1;
        r_index = r_index + 1;
    end
    general_row = general_row + 1;
    f_index = Frame_Data(general_row, 2);
    r_index = 0;
    cur_col = 1;
end

%Show generated image
mesh(Image1);

