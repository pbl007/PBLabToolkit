function varargout = MosaicTiling(varargin)
% MOSAICTILING MATLAB code for MosaicTiling.fig
%      MOSAICTILING, by itself, creates a new MOSAICTILING or raises the existing
%      singleton*.
%
%      H = MOSAICTILING returns the handle to a new MOSAICTILING or the handle to
%      the existing singleton*.
%
%      MOSAICTILING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOSAICTILING.M with the given input arguments.
%
%      MOSAICTILING('Property','Value',...) creates a new MOSAICTILING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MosaicTiling_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MosaicTiling_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MosaicTiling

% Last Modified by GUIDE v2.5 06-Feb-2015 23:45:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MosaicTiling_OpeningFcn, ...
                   'gui_OutputFcn',  @MosaicTiling_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MosaicTiling is made visible.
function MosaicTiling_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MosaicTiling (see VARARGIN)

% Choose default command line output for MosaicTiling
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MosaicTiling wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Upload icons - not working :-( 

icon = imread('Icons/LeftTop.jpg');
set(handles.togglebutton_leftBottom.CData,icon)

%init prmts currently HARDCODED and need to move to pref panes
prmts = [];
% General behavior paramters - HARCODED
prmts.allowManualTileAdjustments = 1;
prmts.computeMaxProjections = 1;
prmts.keepFiles = 0;
prmts.writeMosaicTofile = 0;
prmts.Zpos2use = 1; %HARDCODED - no longer neede for single Z data....
prmts.Zpos2useList = 1;%HARDCODED
prmts.xcorrCh = 3;%channel data to use for cross-correlations
prmts.channels2extract = get(handles.listbox_Channels,'Value');
prmts.channelStackedNames = {'NEUN';'HORD';'FITC'};
%nominal x,y and z offsets
prmts.maxStageErrRCZ = [20 20 Inf];%Max allowed stage offset, larger offsets are set to zero
prmts.nominalYXZ = [0 0 0]; %position of Z01-C01-R01. Adjust in case stage was not set to 0,0,0

setappdata(gcf,'prmts',prmts);



% --- Outputs from this function are returned to the command line.
function varargout = MosaicTiling_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_selectFile.
function pushbutton_selectFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [baseName, path2dir, filterindex] = uigetfile( ...
       {'*.tif','TIF-files (*.tif)'; ...
        '*.mpd','MPD-files (*.mpd)'}, ...
        'Pick a file', ...
        'MultiSelect', 'on');
%populate prmts and store in appdata
prmts = getappdata(gcf,'prmts');
%file name and directories
prmts.baseName = baseName(1:strfind(baseName,'-')-1);
prmts.path2dir = path2dir;
switch filterindex
    case 0
        %user canceled
        return
    case 1
        prmts.fileTypeToUse = 'tif';
    case 2
        prmts.fileTypeToUse = 'mpd';
    otherwise
        %unsupported file type - HALT!
       warndlg('Unsuported file type. Please select ''tif'' or ''mpd'' files')
       return
end
[~,~,prmts.ext]= fileparts(baseName);
prmts.dirContent = dir(prmts.path2dir);

%dataset parameters
switch prmts.fileTypeToUse
    case {'tif'}
        stkInfo = imfinfo(fullfile(prmts.path2dir,baseName));
        prmts.stkWidth = stkInfo(1).Width;
        prmts.stkHeight = stkInfo(1).Height;
        prmts.stkDepth = numel(stkInfo);
        
    case {'mpd'}
        stk = mp2mat(fullfile(prmts.path2dir,baseName),'Header');
        prmts.stkWidth = stk.Header.Frame_Width;
        prmts.stkHeight = stk.Header.Frame_Height;
        prmts.stkDepth = stk.Header.Frame_Count;
end

%update GUI
set(handles.edit_BlockSizeCol,'String',num2str(prmts.stkWidth));
set(handles.edit_blockSizeRow,'String',num2str(prmts.stkHeight));
set(handles.edit_blockSizeZ,'String',num2str(prmts.stkDepth));

setappdata(gcf,'prmts',prmts);




function edit_stepSize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stepSize as text
%        str2double(get(hObject,'String')) returns contents of edit_stepSize as a double


% --- Executes during object creation, after setting all properties.
function edit_stepSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_Channels.
function listbox_Channels_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Channels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Channels


% --- Executes during object creation, after setting all properties.
function listbox_Channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Run.
function pushbutton_Run_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%gather missing prmts information 
prmts = getappdata(gcf,'prmts');
if ~isfield(prmts,'stkWidth')
    warndlg('Please select a file first.')
    return
end
prmts.defaultBlockSize = [prmts.stkWidth prmts.stkHeight prmts.stkDepth];%default file size of each image stack
prmts.xstep = str2double(get(handles.edit_stepSizeCol,'String')); %displacement in Y,X,Z between image stack
prmts.ystep = str2double(get(handles.edit_stepSizeRow,'String'));
prmts.zstep = str2double(get(handles.edit_stepSizeZ,'String'));
prmts.defaultBlockStepSize = [prmts.xstep prmts.ystep prmts.zstep];
prmts.altBlockStepSizeZ = [];

%compute overlap for later use (reconstruction stage)
prmts.overlap_X = prmts.stkWidth - prmts.xstep;
prmts.overlap_Y = prmts.stkHeight - prmts.ystep;
prmts.overlap_Z = prmts.stkDepth - prmts.zstep;

%channel to quickstitch
prmts.channels2extract = get(handles.listbox_Channels,'Value');
if numel(prmts.channels2extract)==1;prmts.xcorrCh = prmts.channels2extract;end

%determine direction based on toggle button on acquisition pattern
acqPattern = get(handles.uibuttongroup1.SelectedObject,'String')   

if strfind(acqPattern,'Top')
prmts.reverseYBlockNumbering = 'no'; %default is no (data taken top to bottom)
else
    prmts.reverseYBlockNumbering = 'yes';
end

if strfind(acqPattern,'Left')
    prmts.reverseXBlockNumbering = 'no';%default is no (data taken left to right)
else
    prmts.reverseXBlockNumbering = 'yes';
end

% get tile positions
prmts = getIrregularMosaicLayout(prmts);

% extract data from files and generate mosaic max projection
prmts = MosaicTiling_extractData(prmts);
MosaicTiling_displayMosaicLayout(prmts,0);


%update fig with prmts
setappdata(gcf,'prmts',prmts);




function edit_stepSizeCol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stepSizeCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_stepSizeCol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stepSizeCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stepSizeRow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stepSizeRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_stepSizeRow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stepSizeRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stepSizeZ_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stepSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_stepSizeZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stepSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_blockSizeZ_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blockSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_blockSizeZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blockSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_blockSizeRow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blockSizeRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_blockSizeRow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blockSizeRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_BlockSizeCol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BlockSizeCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BlockSizeCol as text
set(hObject,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_BlockSizeCol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BlockSizeCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
