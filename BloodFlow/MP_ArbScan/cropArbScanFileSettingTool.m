function varargout = cropArbScanFileSettingTool(varargin)
% CROPARBSCANFILESETTINGTOOL MATLAB code for cropArbScanFileSettingTool.fig
%      CROPARBSCANFILESETTINGTOOL, by itself, creates a new CROPARBSCANFILESETTINGTOOL or raises the existing
%      singleton*.
%
%      H = CROPARBSCANFILESETTINGTOOL returns the handle to a new CROPARBSCANFILESETTINGTOOL or the handle to
%      the existing singleton*.
%
%      CROPARBSCANFILESETTINGTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CROPARBSCANFILESETTINGTOOL.M with the given input arguments.
%
%      CROPARBSCANFILESETTINGTOOL('Property','Value',...) creates a new CROPARBSCANFILESETTINGTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cropArbScanFileSettingTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cropArbScanFileSettingTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cropArbScanFileSettingTool

% Last Modified by GUIDE v2.5 23-Nov-2015 00:03:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cropArbScanFileSettingTool_OpeningFcn, ...
    'gui_OutputFcn',  @cropArbScanFileSettingTool_OutputFcn, ...
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


% --- Executes just before cropArbScanFileSettingTool is made visible.
function cropArbScanFileSettingTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cropArbScanFileSettingTool (see VARARGIN)

% Choose default command line output for cropArbScanFileSettingTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cropArbScanFileSettingTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cropArbScanFileSettingTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_arbMatFiles.
function listbox_arbMatFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_arbMatFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_arbMatFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_arbMatFiles


% --- Executes during object creation, after setting all properties.
function listbox_arbMatFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_arbMatFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_tifFiles.
function listbox_tifFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_tifFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_tifFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_tifFiles


% --- Executes during object creation, after setting all properties.
function listbox_tifFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_tifFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%------------------------------  MY FUNCTIONS -------------------------------
function updateArbScanMatchedList(handles,fileNameList,varargin)
if nargin==2;pos = get(handles.listbox_arbMatFiles,'Value');else pos = varargin{1};end
set(handles.listbox_arbMatFiles,'String',fileNameList,'Value',pos)
handles.arbScanFileNameMatchedList = fileNameList;

function updateTifMatchedList(handles,fileNameList,varargin)
if nargin==2;pos = get(handles.listbox_arbMatFiles,'Value');else pos = varargin{1};end
set(handles.listbox_tifFiles,'String',fileNameList,'Value',pos)
handles.arbScanFileNameMatchedList = fileNameList;

function fileNameList = getArbScanMatchedList(handles)
fileNameList = get(handles.listbox_arbMatFiles,'String');

function fileNameList = getTifScanMatchedList(handles)
fileNameList = get(handles.listbox_tifFiles,'String');




%------------------------------  GUI FUNCTIONS -------------------------------
% --- Executes on button press in pushbutton_getDirectory.
function pushbutton_getDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_getDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path2dir = uigetdir('Select arb scan data directory');
if ~isdir(path2dir);return;end
%got here so process directory
handles.path2dir = path2dir;cd(path2dir);
%update text string
set(handles.text_arbScanSourceDir,'String',path2dir);
% first convert any rpt file to mat by changing the file extension
dirContent = dir([path2dir filesep '*.rpt']);
if numel(dirContent)>0
    if isunix
        %a bit of a cryptic command as not all unix distro come with the rename bash command
        %tested on OSX
        cmd = 'ls *.rpt | xargs -I {} sh -c ''mv $1 `basename $1 .rpt`.mat'' - {}';
    else
        cmd = 'rename *.rpt *.mat';
    end
    system(cmd)
end

dirContent = dir([path2dir filesep '*.mat']);
%populate scanData listbox
updateArbScanMatchedList(handles,{dirContent.name});

%populate tif listbox 
dirContent = dir([path2dir filesep '*.tif']);
updateTifMatchedList(handles,{dirContent.name});



% --- Executes on button press in pushbutton_GO.
function pushbutton_GO_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%first things first - abort if file name lists differ in size
arbFileNameList = getArbScanMatchedList(handles);
tifFileNameList = getTifScanMatchedList(handles);

nArbFiles = numel(arbFileNameList);
if nArbFiles ~= numel(tifFileNameList)
    warndlg('The two lists must have the same number of elements')
    return
end

%gater options
options.doUpdateTifName = get(handles.checkbox_matchCroppedTifName,'Value');
options.doMakeThumb = get(handles.checkbox_genThumbnail,'Value');

%%
for iF = 1 : nArbFiles
    thisArbFile = arbFileNameList{iF};
    thisTifFile = tifFileNameList{iF};
    cropArbScan(thisArbFile,thisTifFile,options);
end%cycling files


% --- Executes on button press in checkbox_matchCroppedTifName.
function checkbox_matchCroppedTifName_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_matchCroppedTifName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_matchCroppedTifName


% --- Executes on button press in checkbox_genThumbnail.
function checkbox_genThumbnail_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_genThumbnail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_genThumbnail


% --- Executes on button press in pushbutton_moveUpArb.
function pushbutton_moveUpArb_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveUpArb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNameList = getArbScanMatchedList(handles);
pos = get(handles.listbox_arbMatFiles,'value');
%move up only if pos is not first
if pos==1
    return
end
pos2shift=[pos;pos-1];
fileNameList(pos2shift) = fileNameList(pos2shift([2 1]));
updateArbScanMatchedList(handles,fileNameList,pos-1);

% --- Executes on button press in pushbutton_moveDownArb.
function pushbutton_moveDownArb_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveDownArb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNameList = getArbScanMatchedList(handles);
pos = get(handles.listbox_arbMatFiles,'value');
%move down only if pos is not last
if pos==numel(fileNameList)
    return
end
pos2shift=[pos;pos+1];
fileNameList(pos2shift) = fileNameList(pos2shift([2 1]));
updateArbScanMatchedList(handles,fileNameList,pos+1)

% --- Executes on button press in pushbutton_deleteScanData.
function pushbutton_deleteScanData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deleteScanData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNameList = getArbScanMatchedList(handles);
pos = get(handles.listbox_arbMatFiles,'value');
ids=1:numel(fileNameList);
if numel(ids)==1;warndlg('Cannot delete last one');return;end
ids2keep = setdiff(ids,pos);
fileNameList = fileNameList(ids2keep);
if pos>numel(fileNameList);pos=numel(fileNameList);end
updateArbScanMatchedList(handles,fileNameList,pos)

% --- Executes on button press in pushbutton_moveUpTif.
function pushbutton_moveUpTif_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveUpTif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNameList = getTifScanMatchedList(handles);
pos = get(handles.listbox_tifFiles,'value');
%move up only if pos is not first
if pos==1
    return
end
pos2shift=[pos;pos-1];
fileNameList(pos2shift) = fileNameList(pos2shift([2 1]));
updateTifMatchedList(handles,fileNameList,pos-1)


% --- Executes on button press in pushbutton_moveDownTif.
function pushbutton_moveDownTif_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveDownTif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNameList = getTifScanMatchedList(handles);
pos = get(handles.listbox_tifFiles,'value');
%move down only if pos is not last
if pos==numel(fileNameList)
    return
end
pos2shift=[pos;pos+1];
fileNameList(pos2shift) = fileNameList(pos2shift([2 1]));
updateTifMatchedList(handles,fileNameList,pos+1)


% --- Executes on button press in pushbutton_deleteTif.
function pushbutton_deleteTif_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deleteTif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNameList = getTifScanMatchedList(handles);
pos = get(handles.listbox_tifFiles,'value');
ids=1:numel(fileNameList);
if numel(ids)==1;warndlg('Cannot delete last one');return;end
ids2keep = setdiff(ids,pos);
fileNameList = fileNameList(ids2keep);
if pos>numel(fileNameList);pos=numel(fileNameList);end
updateTifMatchedList(handles,fileNameList,pos)
