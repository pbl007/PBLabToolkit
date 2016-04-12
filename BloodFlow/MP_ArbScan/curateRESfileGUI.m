function varargout = curateRESfileGUI(varargin)
% CURATERESFILEGUI MATLAB code for curateRESfileGUI.fig
%      CURATERESFILEGUI, by itself, creates a new CURATERESFILEGUI or raises the existing
%      singleton*.
%
%      H = CURATERESFILEGUI returns the handle to a new CURATERESFILEGUI or the handle to
%      the existing singleton*.
%
%      CURATERESFILEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CURATERESFILEGUI.M with the given input arguments.
%
%      CURATERESFILEGUI('Property','Value',...) creates a new CURATERESFILEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before curateRESfileGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to curateRESfileGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help curateRESfileGUI

% Last Modified by GUIDE v2.5 10-Apr-2016 21:32:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @curateRESfileGUI_OpeningFcn, ...
    'gui_OutputFcn',  @curateRESfileGUI_OutputFcn, ...
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

% --- Executes just before curateRESfileGUI is made visible.
function curateRESfileGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to curateRESfileGUI (see VARARGIN)

% Choose default command line output for curateRESfileGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

linkaxes(findobj(gcf,'type','axes'),'x');

% UIWAIT makes curateRESfileGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = curateRESfileGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu_selectResFileName.
function popupmenu_selectResFileName_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectResFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_selectResFileName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_selectResFileName

%when file is selected from popupmenu. display data.
h2fig = gcf;
inRESfileNames = getappdata(h2fig,'inRESfileNames');
thisPopmenuEntry = get(gcbo,'Value');
thisFileName = inRESfileNames{thisPopmenuEntry};
RES_FILES_COMPILED = getappdata(h2fig,'RES_FILES_COMPILED');
ROI_Selections = getappdata(h2fig,'ROI_Selections');
rows=(strcmp(RES_FILES_COMPILED.RESfileName,thisFileName));% index into relevant rows;

%% populate graph
T=RES_FILES_COMPILED(rows,:);
t=cell2mat(T{1,'t'});
%parse rows into diameter, velocity and intensity. Velocity is a special
%case as it can be computed using different methods so name is not unique
rowsDiamIdx=find(strcmp(T.varType,'diameter_um'));
rowsIntensityIdx = find(strcmp(T.varType,'intensity'));
rowsVelocityIdx = find(strcmp(T.varType,'radon_um_per_s'));


axes(handles.axes_diameter)
if ~isempty(rowsDiamIdx)
    y=cell2mat(T{rowsDiamIdx,'y'});
    y=hampel(y,4,2);
    plot(t,y)
    ylabel('Diameter (\mum)');
    xlabel('Time(s)');
    axis tight
    legend(strrep(T{rowsDiamIdx,'name'},'_','\_'))
else
    cla
end

axes(handles.axes_velocity)
if ~isempty(rowsVelocityIdx)

    y=cell2mat(T{rowsVelocityIdx,'y'});
    y=hampel(y,4,2);
    plot(t,y)
    ylabel('Velocisty (\mum \times s^{-1})');
    xlabel('Time(s)');
    axis tight
    legend(strrep(T{rowsVelocityIdx,'name'},'_','\_'))
else
    cla
end

axes(handles.axes_intensity)
if ~isempty(rowsIntensityIdx)
    y=cell2mat(T{rowsIntensityIdx,'y'});
    y=hampel(y,4,2);
    plot(t,y)
    ylabel('Intensity(a.u.)');
    xlabel('Time(s)');
    axis tight
        legend(strrep(T{rowsIntensityIdx,'name'},'_','\_'))
else
    cla
end

%store currently displayed data in appdata
setappdata(h2fig,'currentData',T);
setappdata(h2fig,'rowsIDs',rows);
setappdata(h2fig,'t',t);%this is the time data, will need it to find out selected range.

%% check if ROIs where selected for this RES file

if ~isempty(ROI_Selections)
    %deal only wiht 'Active' ROI (i.e. we ignore Status 'Deleted')
    ROI_Selections = ROI_Selections(strcmp(ROI_Selections.Status,'Active'),:);
    hasSelectedRegions = strfind(ROI_Selections.fileName,thisFileName);
    hasSelectedRegions = find(cell2mat(cellfun(@(x) ~isempty(x), hasSelectedRegions, 'UniformOutput',false)));
    if ~isempty(hasSelectedRegions)
        for iSELEC = 1 : numel(hasSelectedRegions)
            Xi = cell2mat(ROI_Selections{hasSelectedRegions(iSELEC),'Range_Xi'});
            thisID = ROI_Selections{hasSelectedRegions(iSELEC),'ID'};
            selectionType = cell2mat(ROI_Selections{hasSelectedRegions(iSELEC),'SelectionType'});
            %create ROI
            doWithSelectedRegion(Xi,selectionType,handles,1,thisID)% the 1 tells to display only.
        end
    end
end

% --- Executes during object creation, after setting all properties.
function popupmenu_selectResFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectResFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Select'});


% --- Executes on button press in pushbutton_selectToKeep.
function pushbutton_selectToKeep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectToKeep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.brush = brush;
% set(handles.brush, 'Enable', 'on', 'ActionPostCallback', @keepBrushedData,'color','g');

if(get(gcbo,'Value'))
    [Xi,~]=ginput(2);
    set(gcbo,'Value',0);%release toggle
    doWithSelectedRegion(Xi,'keep',handles)
end

% --- Executes on button press in pushbutton_selectToRemove.
function pushbutton_selectToRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectToRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.brush = brush
% set(handles.brush, 'Enable', 'on', 'ActionPostCallback', @removeBrushedData,'color','r');
%

if(get(gcbo,'Value'))
    [Xi,~]=ginput(2);
    set(gcbo,'Value',0);%release toggle
    doWithSelectedRegion(Xi,'remove',handles)
end

function doWithSelectedRegion(Xi,selectionType,handles,varargin)
%This function adds a rectangle over the selected area and updates the
%table. If using update only mode, it is called to display ROI for wich
%table entries exist, just display and return

displayOnly = 0;
if nargin>3
    displayOnly=varargin{1};
    thisID = varargin{2};
end

%check if selection is valid (unit of time, not linear indices)

h2fig = gcf;
if ~displayOnly %no need to get data and validate Xi limits
    currentData = getappdata(h2fig,'currentData');
    t = currentData.t{:};
    nt = numel(t);
    Xi(Xi<0)=1;
    Xi(Xi>t(end))=nt;
    
    
end% needed for display and update

% we will create an entry for each selection so they can be easily managed
ROI_Selections = getappdata(h2fig,'ROI_Selections');
rowIds = find(getappdata(h2fig,'rowsIDs'));
RES_FILES_COMPILED = getappdata(h2fig,'RES_FILES_COMPILED');
if isempty(ROI_Selections)
    ROI_Selections = table([],[],[],[],[],[],[],[],'VariableNames',{'ID','fileName','rowIDs','Range','Range_Xi','SelectionType','Status','ptr2ROIhandles'});
    lastID = 0;
else
    lastID = ROI_Selections.ID(end);
end


switch selectionType
    case 'keep'
        patchColor = 'g';
        selectionValue = 1;
    case 'remove'
        patchColor = 'r';
        selectionValue = 0;
end


h2axes = [handles.axes_diameter,handles.axes_intensity,handles.axes_velocity];
h2ROIs = zeros(numel(h2axes),1);% we currently link all data together - store ROI for all data types 

%pointer to row in ROI_Selection table
if ~displayOnly
    thisID = lastID + 1;
end

for iAXES = 1 : numel(h2axes)
    h2fig.CurrentAxes = h2axes(iAXES);
%     zoom out
    [yLims] = get(gca,'ylim');
    h2ROIs(iAXES)=patch([Xi(1) Xi(1) Xi(2) Xi(2)],[yLims(1) yLims(2) yLims(2) yLims(1)],patchColor,'FaceAlpha',0.1);
    set(h2ROIs(iAXES),'userdata',h2ROIs(iAXES))
    %add ROI action menus
    c = uicontextmenu;
    set(h2ROIs(iAXES),'UIContextMenu',c)
    uimenu(c,'Label','Delete','Callback',@deleteROI,'userdata',thisID);
end

if displayOnly %no need to go beyond this point if displaying only
    %update corresponding rows

    ROI_Selections.ptr2ROIhandles{thisID} = h2ROIs;
    
    %update corresponding rows    
    setappdata(gcf,'ROI_Selections',ROI_Selections);
    setappdata(h2fig,'RES_FILES_COMPILED',RES_FILES_COMPILED)
    return
end
    
%% store selection and updated data tables
t_selected = currentData.t_selected{1};

%ginput (as opposed to brush) does return a coordinate scaled to the values
%of the time axis (in time axis untis).
tIdx1 = find(t<=Xi(1)+0.05 & t>=Xi(1)-0.05);
tIdx1 = tIdx1(ceil(numel(tIdx1)/2));
tIdx2 = find(t<=Xi(2)+0.05 & t>=Xi(2)-0.05);
tIdx2 = tIdx2(ceil(numel(tIdx2)/2));

%SANITY CHECK SELECTED RANGE
%use might have clicked second point first, ensure we go from smaller to
%larger

if tIdx1>tIdx2;tmp=tIdx1;tIdx1 = tIdx2;tIdx2 = tmp;end
if tIdx1<1;tIdx1=1;end
if tIdx2>numel(t);tIdx2=nt;end
    
if isempty(t_selected)
    fprintf('\nEmpty t_selected');
    t_selected = repmat(-1,nt,1);
end

%check if this is the first time something is selected for this file
if all(t_selected==-1)
    fprintf('\nAll -1')
    switch selectionType
        case 'keep'
            %unselect all
            t_selected = zeros(size(t),'uint8');
        otherwise
            %select all as this is a delete 
            t_selected = ones(size(t),'uint8');
    end
end


newRow = {thisID, currentData.RESfileName{1},rowIds, [tIdx1 tIdx2],Xi ,selectionType,'Active',h2ROIs};
ROI_Selections = [ROI_Selections; cell2table(newRow,'VariableNames',{'ID','fileName','rowIDs','Range','Range_Xi','SelectionType','Status','ptr2ROIhandles'})];


t_selected(tIdx1:tIdx2) = selectionValue; %first initialized to -1, selected = 1, skipped = 0;
currentData.t_selected = repmat({t_selected},size(currentData,1),1);%has to update this table as well since the current data is only update once a new file is selected.

RES_FILES_COMPILED = computeNewStats(RES_FILES_COMPILED,rowIds,t_selected);
% %update corresponding rows
% for iROW = 1 : numel(rowIds);
%     RES_FILES_COMPILED.t_selected{rowIds(iROW)} = t_selected;
%     [y_selected_mean, y_selected_std] = computeNewStats(RES_FILES_COMPILED.y{rowIds(iROW)},t_selected);
%     RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)) = y_selected_mean;
%     RES_FILES_COMPILED.y_selected_std(rowIds(iROW)) = y_selected_std;
% %     
% %     RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)) = mean(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
% %     RES_FILES_COMPILED.y_selected_std(rowIds(iROW)) = std(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
% 
%     fprintf('\n Original values for row %d where %3.4f±%3.4f, now  %3.4f±%3.4f',rowIds(iROW),...
%         RES_FILES_COMPILED.y_mean(rowIds(iROW)),RES_FILES_COMPILED.y_std(rowIds(iROW)),...
%         RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)),RES_FILES_COMPILED.y_selected_std(rowIds(iROW)));
% 
% 
% end

setappdata(h2fig,'ROI_Selections',ROI_Selections);
setappdata(h2fig,'RES_FILES_COMPILED',RES_FILES_COMPILED)
setappdata(h2fig,'currentData',currentData);
saveUpdatedData


function RES_FILES_COMPILED = computeNewStats(RES_FILES_COMPILED,rowIds,t_selected)
%update corresponding rows
for iROW = 1 : numel(rowIds);
    RES_FILES_COMPILED.t_selected{rowIds(iROW)} = t_selected;
    
    y_selected_mean = mean(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    y_selected_std = std(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    
    RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)) = y_selected_mean;
    RES_FILES_COMPILED.y_selected_std(rowIds(iROW)) = y_selected_std;
    %
    %     RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)) = mean(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    %     RES_FILES_COMPILED.y_selected_std(rowIds(iROW)) = std(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    
    fprintf('\n Original values for row %d where %3.4f±%3.4f, now  %3.4f±%3.4f',rowIds(iROW),...
        RES_FILES_COMPILED.y_mean(rowIds(iROW)),RES_FILES_COMPILED.y_std(rowIds(iROW)),...
        RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)),RES_FILES_COMPILED.y_selected_std(rowIds(iROW)));


end



function deleteROI(varargin)
%%
h2fig = gcf;
thisROI_ID = get(gcbo,'UserData');
T = getappdata(h2fig,'ROI_Selections');
currentData = getappdata(h2fig,'currentData');
rowIds = find(getappdata(h2fig,'rowsIDs'));
RES_FILES_COMPILED = getappdata(h2fig,'RES_FILES_COMPILED');
ptr2ROIhandles = T{thisROI_ID,'ptr2ROIhandles'};
delete(ptr2ROIhandles{1})


%%
rowIds = T.rowIDs{thisROI_ID};
selectedRange = T.Range(thisROI_ID,:);
t_selected = RES_FILES_COMPILED.t_selected{rowIds(1)};
t_selected(selectedRange(1):selectedRange(2))=~mean(t_selected(selectedRange(1):selectedRange(2))); %invert selection
currentData.t_selected = repmat({t_selected},size(currentData,1),1);%has to update this table as well since the current data is only update once a new file is selected.
RES_FILES_COMPILED = computeNewStats(RES_FILES_COMPILED,rowIds,t_selected);

%update corresponding rows
for iROW = 1 : numel(rowIds);
    RES_FILES_COMPILED.t_selected{rowIds(iROW)} = t_selected;
end

%update ROI and data tables
T.Status{thisROI_ID} = 'deleted';
setappdata(gcf,'ROI_Selections',T);
setappdata(h2fig,'RES_FILES_COMPILED',RES_FILES_COMPILED);
setappdata(h2fig,'currentData',currentData);

saveUpdatedData

function saveUpdatedData(varargin)
%this functions gathers variables to save and saves as mat file
h2fig = gcf;
ROI_Selections = getappdata(h2fig,'ROI_Selections');
RES_FILES_COMPILED = getappdata(h2fig,'RES_FILES_COMPILED');
UPDATED_RESFileName = getappdata(h2fig,'UPDATED_RESFileName');
path2ResFile = getappdata(h2fig,'path2ResFile');
save(fullfile(path2ResFile,UPDATED_RESFileName),'ROI_Selections','RES_FILES_COMPILED')

%%

% --- Executes on button press in pushbutton_loadResFile.
function pushbutton_loadResFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadResFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[RESFileName,path2ResFile] = uigetfile();

cd (path2ResFile)
load(fullfile(path2ResFile,RESFileName));

%set the name for the file
%check first if this file is already an "update" on
stri = strfind(RESFileName,'_UPDATED');
if ~isempty(stri)
    baseName = RESFileName(1:stri-1);
else
   [~,baseName] = fileparts(RESFileName);
end
timeStamp = datestr(now,'yyyymmdd_HHMM');
UPDATED_RESFileName = [baseName '_UPDATED_' timeStamp];

%work with table, easy to manipulate than struct
if ~istable(RES_FILES_COMPILED)
    RES_FILES_COMPILED = struct2table(RES_FILES_COMPILED);
end

%group lines by RES
[inRESfileNamesIDs,inRESfileNames]=findgroups(RES_FILES_COMPILED.RESfileName);

%initialize selection table variable, if it does not exist
if ~ismember('t_selected',RES_FILES_COMPILED.Properties.VariableNames)
    RES_FILES_COMPILED{:,'t_selected'} = {[]};
    nRows = size(RES_FILES_COMPILED,1);
    RES_FILES_COMPILED.y_selected_mean = nan(nRows,1);
    RES_FILES_COMPILED.y_selected_std = nan(nRows,1);
    for iFILE = 1 : max(inRESfileNamesIDs)
        %find out number of points
        iRow = find(inRESfileNamesIDs==iFILE);
        nPoints = numel(RES_FILES_COMPILED{iRow(1),'t'}{1});
        t_selected = repmat(-1,nPoints,1);
        RES_FILES_COMPILED{iRow,'t_selected'}=repmat({t_selected},numel(iRow),1);
    end
end


h2fig = gcf;
set(handles.popupmenu_selectResFileName,'String',inRESfileNames)
setappdata(h2fig,'inRESfileNames',inRESfileNames);
setappdata(h2fig,'inRESfileNamesIDs',inRESfileNamesIDs);
setappdata(h2fig,'RESFileName',RESFileName);
setappdata(h2fig,'RES_FILES_COMPILED',RES_FILES_COMPILED);
setappdata(h2fig,'UPDATED_RESFileName',UPDATED_RESFileName);
setappdata(h2fig,'path2ResFile',path2ResFile);


%if file contained a selection table, store it in appdata
if exist('ROI_Selections','var')
    setappdata(h2fig,'ROI_Selections',ROI_Selections);
end

%trigger display
popupmenu_selectResFileName_Callback(handles.popupmenu_selectResFileName, eventdata, handles)


% --- Executes on button press in pushbutton_selectToKeepAll.
function pushbutton_selectToKeepAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectToKeepAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentData = getappdata(handles.figure1,'currentData');
t = currentData.t{1};
Xi=[t(1); t(end)];

doWithSelectedRegion(Xi,'keep',handles)

% --- Executes on button press in pushbutton_selectToRemoveAll.
function pushbutton_selectToRemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectToRemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentData = getappdata(handles.figure1,'currentData');
t = currentData.t{1};
Xi=[t(1); t(end)];

doWithSelectedRegion(Xi,'remove',handles)



% function keepBrushedData(hObj,eventdata)
% %currently we great all lines together so identify boundary of selected
% %data (we keep all, an alternative will be to keep the actual selected data
% %the problem is that this is not systematic, not like keeping x+2*std(x)
% nlines = length(eventdata.Axes.Children);
% brushdata = cell(nlines, 1);
% 
% t = single(getappdata(gcf,'t')); %for some reason the returned values from the brushed data are single.
% 
% for ii = 1:nlines
%     ii
%     brushdata{ii} = eventdata.Axes.Children(ii).BrushHandles.Children(1).VertexData;
%     X = brushdata{ii}';
%     if ~isempty(X)
%         tmin = min(X(:,1));
%         tmax = max(X(:,1));
%         find(t==tmin)
%         find(t==tmax)
%         break
%     end
% end
% 
% function removeBrushedData(~,eventdata)
% 
% 
% function displayBrushData(~, eventdata)
% nlines = length(eventdata.Axes.Children);
% brushdata = cell(nlines, 1);
% for ii = 1:nlines
%     brushdata{ii} = eventdata.Axes.Children(ii).BrushHandles.Children(1).VertexData;
%     fprintf('Line %i\n', ii)
%     fprintf('X: %f Y: %f Z: %f\n', brushdata{ii})
% end


% --- Executes on button press in pushbutton_showREStable.
function pushbutton_showREStable_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_showREStable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h2fig = gcf;
RES_FILES_COMPILED = getappdata(h2fig,'RES_FILES_COMPILED');

h2REStable = figure('Name','RES_FILES_COMPILED');
t = uitable('Parent',h2REStable,'Units','normalized','Position',[0 0 1 1]);
%put numeric types at the end
cols2display = {'animalID','conditionID','RESfileName','name','varType','y_mean','y_std','y_selected_mean','y_selected_std'};
numericDataStartsAt = 6;
cols2displayNumeric = cols2display(numericDataStartsAt:numel(cols2display));
t.ColumnName = cols2display;
t.Data = [RES_FILES_COMPILED{:,cols2display(1:numericDataStartsAt-1)} num2cell(RES_FILES_COMPILED{:,cols2displayNumeric})];

% --- Executes on button press in pushbutton_showSelectedT.
function pushbutton_showSelectedT_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_showSelectedT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentData = getappdata(handles.figure1,'currentData');
t_selected = cell2mat(currentData{1,'t_selected'});
t = cell2mat(currentData{1,'t'});
figure;plot(t,t_selected,'lineWidth',2);
box off