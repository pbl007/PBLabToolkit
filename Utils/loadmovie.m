function varargout = loadmovie(varargin);
%
%This function loads an entire image stack (stored as a multistack
%.tif file one frame at a time to avoid overflowing memory.
%
%Input arguments are stored in the structure myparameters as:
%   myparameters.input_filename =  path & filename string of desired file
%   myparameters.read_start = start frame to read
%   myparameters.read_stop = stop frame to read
%   myparameters.convert_type = uint8,uint16,int16,single,double(default = uint16)
%   myparemeters.convert_min = min value for conversion (default = 0)
%   myparameters.convert_max = max value for conversion (default = 2048)
%   myparameters.save_mat = 'yes', 'on', 'savemat' saves a .mat file
%   myparameters.waitbar_yn = 'yes' or 'no' to display waitbar
%   myparameters.window_prompt = 'Choose an Image file'
%Output argument is the 3D matrix containng thedata.
%If no input variable is given, a user input window displays.
%If the first input argument is not a structure, it is assumed to be a
%the input_filename string
%
%USE:
%MYPICS = LOADMOVIE;
%MYPICS = LOADMOVIE(INPUT_FILENAME, READ_START, READ_STOP, CONVERT_TYPE, CONVERT_MIN, CONVERT_MAX, SAVE_MAT,WINDOW_PROMPT);
%MYPICS = LOADMOVIE(MYPARAMETERS);
%[MYPICS,MYPARAMETERS] = LOADMOVIE(MYPARAMETERS);
%[MYPICS,MYPARAMETERS] = LOADMOVIE('','','','','','','','yes','Prompt');
%   to convert to a .mat file
%
% Written by Phil Tsai 01/10/05
% Last Updated 12/22/06


%EXTRACT INPUT PARAMETERS, IF THEY EXIST
nin = nargin;
nout = nargout;
myargin = varargin;
myargin{100} = '';
if nin >0,
    if isstruct(myargin{1}),
        myparameters = myargin{1};
    else%if isstruct(myargin{1})
        myparameters.input_filename = myargin{1};
        myparameters.read_start = myargin{2};
        myparameters.read_stop = myargin{3};
        myparameters.convert_type = myargin{4};
        myparameters.convert_min = myargin{5};
        myparameters.convert_max = myargin{6};
        myparameters.save_mat = myargin{7};
        myparameters.waitbar_yn = myargin{8};
        myparameters.window_prompt = myargin{9};
    end%if isstruct(myargin{1})
else%if nin>0
    myparameters = [];
end
input_filename = readparameters(myparameters,'input_filename','');
read_start = readparameters(myparameters,'read_start',1);
read_stop = readparameters(myparameters,'read_stop',999999);
convert_type = readparameters(myparameters,'convert_type','uint16');
convert_min = readparameters(myparameters,'convert_min',0);
convert_max = readparameters(myparameters,'convert_max',2047);
save_mat = readparameters(myparameters,'save_mat','no');
waitbar_yn = readparameters(myparameters,'waitbar_yn','yes');
window_prompt = readparameters(myparameters,'window_prompt','Choose an image file');

start_frame = readparameters(myparameters,'start_frame',0);
stop_frame = readparameters(myparameters,'stop_frame',0);
if start_frame>0, read_start = start_frame; end
if stop_frame>0, read_stop = stop_frame; end


%DETERMINE FILENAME FOR OPENING
if isempty(input_filename),
    [filename,pathname] = uigetfile('*.tif',window_prompt);
    input_filename = [pathname,filename];
    myparameters.input_filename = filename;
    cd(pathname);
else%if isempty(input_filename)
    passed_path_filename = input_filename;
    [junk,filename_size] = size(passed_path_filename);
    endpath = max(findstr(passed_path_filename,filesep)); %location of last \ in path
    if isempty(endpath) %if only the filename alone was entered
        pathname = cd;
        input_filename = [pathname,filesep,passed_path_filename];
        filename = passed_path_filename;
    else%isempty(endpath)
        input_filename = passed_path_filename;
        filename = passed_path_filename(endpath+1:filename_size);
        pathname = passed_path_filename(1:endpath);
    end%if isemtpy(endpath)
end%if isempty(input_filename)

myinfo = imfinfo(input_filename);
num_frames = length(myinfo);
x_size = myinfo(1).Height;
y_size = myinfo(1).Width;
ColorType = myinfo(1).ColorType;
mystart = read_start;
mystop = min(read_stop,num_frames);

saveas_suffix = '.mat';
temp = size(filename);
temp2 = temp(2)-4;
temp3 = filename(1,1:temp2);
mat_filename = [temp3,saveas_suffix];
mat_pathname = pathname;
mat_fullname = [pathname,mat_filename];

switch convert_type
    case 'uint8', mybit = uint8(0); maxval = 255;
    case 'unit16', mybit = uint16(0); maxval = 2047;
    case 'int16', mybit = int16(0); maxval = 2047;
    case 'single', mybit = single(0); maxval = 2047;
    case 'double', mybit = double(0); maxval = 2047;
    otherwise, mybit = uint16(0);
end

if strcmp(ColorType,'truecolor');
    mypics = repmat(mybit,[x_size,y_size,(mystop+1-mystart)*3]);
    RGB = 1;
else
    mypics = repmat(mybit,[x_size,y_size,mystop+1-mystart]);
    RGB = 0;
end

waitbar_on = 0;
switch waitbar_yn
    case {'yes','y','Y','Yes','YES'}
        wb = waitbar(0,['Loading file ',filename,'...']);
        waitbar_on = 1;
end

for k=mystart:mystop,
    temppic = imread(input_filename,k);
    convert_yn = readparameters(myparameters,'convert_type','no');
    
    if ~strcmp(convert_yn,'no'),
        temppic = double(temppic);
        temppic = temppic-convert_min;
        temppic = max(temppic,0);
        temppic = maxval * temppic / (convert_max - convert_min);
    end

    if RGB == 0,
        mypics(:,:,k-mystart+1) = temppic;
    else
        mypics(:,:,(k-mystart+1)*3 : (k-mystart+1)*3 +2) = temppic;
    end

    if waitbar_on == 1, waitbar((k-mystart)/(mystop+1-mystart),wb); end
end
if waitbar_on ==1, close(wb); end

switch save_mat,
    case {'on','yes','savemat'}
        save(mat_fullname,'mypics');
        myparameters.mat_filename = mat_filename;
        myparameters.mat_pathname = mat_pathname;
    otherwise
end

varargout{1} = mypics;
if nout >1,
    varargout{2} = myparameters;
end

return%function





function output_parameter = readparameters(paramstruct,parameter_name,default_value);
    if isfield(paramstruct,parameter_name),
        if ~isempty(paramstruct.(parameter_name))
            output_parameter = paramstruct.(parameter_name);
        else
            output_parameter = default_value;
        end
    else
        output_parameter = default_value;
    end
return
