function varargout = AG_GUI(varargin)
% AG_GUI MATLAB code for AG_GUI.fig
%      AG_GUI, by itself, creates a new AG_GUI or raises the existing
%      singleton*.
%
%      H = AG_GUI returns the handle to a new AG_GUI or the handle to
%      the existing singleton*.
%
%      AG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AG_GUI.M with the given input arguments.
%
%      AG_GUI('Property','Value',...) creates a new AG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AG_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AG_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AG_GUI

% Last Modified by GUIDE v2.5 20-Dec-2015 15:03:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AG_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AG_GUI_OutputFcn, ...
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


% --- Executes just before AG_GUI is made visible.
function AG_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AG_GUI (see VARARGIN)

% Choose default command line output for AG_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

UIWAIT makes AG_GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AG_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MotorOne.
function MotorOne_Callback(hObject, eventdata, handles)
% hObject    handle to MotorOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MotorTwo.
function MotorTwo_Callback(hObject, eventdata, handles)
% hObject    handle to MotorTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Last_N_Choices_Callback(hObject, eventdata, handles)
% hObject    handle to Last_N_Choices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_N_Choices as text
%        str2double(get(hObject,'String')) returns contents of Last_N_Choices as a double


% --- Executes during object creation, after setting all properties.
function Last_N_Choices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Last_N_Choices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Last_N_Licks_Callback(hObject, eventdata, handles)
% hObject    handle to Last_N_Licks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_N_Licks as text
%        str2double(get(hObject,'String')) returns contents of Last_N_Licks as a double


% --- Executes during object creation, after setting all properties.
function Last_N_Licks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Last_N_Licks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function N_Trials_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N_Trials_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Response_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Response_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Response_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Response_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Response_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Response_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ITI_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to ITI_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ITI_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of ITI_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function ITI_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ITI_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Vacuum_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Vacuum_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vacuum_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Vacuum_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Vacuum_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vacuum_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Punishment_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Punishment_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Punishment_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Punishment_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Punishment_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Punishment_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tone_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Tone_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tone_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Tone_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Tone_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tone_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MouseID_Input_Callback(hObject, eventdata, handles)
% hObject    handle to MouseID_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MouseID_Input as text
%        str2double(get(hObject,'String')) returns contents of MouseID_Input as a double


% --- Executes during object creation, after setting all properties.
function MouseID_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MouseID_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Sample_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Sample_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sample_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Sample_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Sample_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sample_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Retention_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Retention_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Retention_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Retention_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Retention_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Retention_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function N_Trials_Input_Callback(hObject, eventdata, handles)
% hObject    handle to N_Trials_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N_Trials_Input as text
%        str2double(get(hObject,'String')) returns contents of N_Trials_Input as a double


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
