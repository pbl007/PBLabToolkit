function varargout = pathAnalyzeGUI(varargin)
% GUI to analyse the data scanned with pathGUI

% change log:
% 2009-12-14: fixed 'rename' function
% 2009-08-07: correct scaling
% 2009-08-07: newest version
% 2009-05-18: now loads header in handles.dataMpd.Header
% 2009-05-07: now only loading part of the data at a time, for longer datasets
% 2009-04-02: added code to cut out sub-objects in intensity and look
% 2009-03-19: usable code, does diameters, draws paths, etc.
% 2011-02-19: now work to queue for offline analysis
% DATA ANALYSIS magic number 2^20 These lines were added to allow the program to stop
% before crashing CELINE MATEO 20111116
% CELINE MATEO implement to get the name of the file in the command window
% CELINE MATEO change to get the mirror voltage = to 2.5 V for Rig 2 this
% is found in the PATH GUI FILE
%
% PB - implemented analysis of tiff instead of mpd
% PB - implemented support of parallel processing (parfor)
% 2015-11-19 PABLO BLINDER 


% Last Modified by GUIDE v2.5 22-Nov-2015 22:03:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pathAnalyzeGUI_OpeningFcn, ...
    'gui_OutputFcn',  @pathAnalyzeGUI_OutputFcn, ...
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


% --- Executes just before pathAnalyzeGUI is made visible.
function pathAnalyzeGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;  % Choose default command line output for pathAnalyzeGUI

%% user code here ...
handles.scanData = [];            % data from MATLAB, initialize to empty
handles.scanResult3d = [];        % data from mpscope, initialize to empty
handles.scanResult2d = [];        % data from mpscope, initialize to empty
handles.scanResult1d = [];        % data from mpscope, initialize to empty

handles.fileDirectory = mfilename('fullpath');     % initial file directory - PB modified for cross platform support
handles.fileNameMat = '';         % holds name of Matlab file
handles.fileNameArbData = '';         % holds name of Mpd file
handles.imageCh = 1;              % holds imaging channel to load
% selected with pop-up, but default to 1

% code for analysing data later
handles.analyseLater = false;
handles.analyseLaterFilename = '';     % fid to write structures to analyse later
handles.analyseLaterIndex = 0;         % not currently used
handles.analyseLaterLastLoadedMatFile = ''; %PB - every time this changes, we tell the analyze later to flag for storing results (in helper) to separate mat file RES_xxxx.mat


%mjp 2011.05.02
set(gcf,'name','pathAnalyzeExtraGUI v0.3')

%pb 2015.11.15
set(gcf,'name','pathAnalyzeExtraGUI v1.0(PBlab)')


guidata(hObject, handles); % Update handles structure

% UIWAIT makes pathAnalyzeGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = pathAnalyzeGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% --- BUTTON - Load Data - MATLAB
function pushButtonLoadDataMat_Callback(hObject, eventdata, handles)
[handles.fileNameMat,handles.fileDirectory,handles.fileExt] = uigetfile({'*.mat'},'open file - MATLAB (*.mat)',pwd); % open file
% MATEO 20120313
MATEO_MAT_NAME=fullfile (handles.fileDirectory,handles.fileNameMat); display (MATEO_MAT_NAME)
% END MATEO 20120313
if isequal(handles.fileNameMat,0)                      % check to make sure a file was selected
    return
end

fileExt = handles.fileNameMat(end-3:end);       % make sure selected file was right type (mat or rpt)
if ~sum(strcmpi(fileExt,{'.mat'}) )
    % not an .mat file
    errordlg('Oops - needs to be an .mat (MATLAB) or .rtp file')
    return
end

set(handles.figure1,'Name',['pathAnalyzeGUI     ' handles.fileNameMat '     ' handles.fileNameArbData]);

load([handles.fileDirectory handles.fileNameMat]);      % load the MATLAB data here

handles.scanData = scanData;                            % place scan data in handles

guidata(hObject, handles);                              % Update handles structure

pushButtonResetImage_Callback(hObject, eventdata, handles);  % draw image

cd(handles.fileDirectory)


% --- BUTTON - Load Data MpScope
function pushButtonLoadData_Callback(hObject, eventdata, handles)

%PB - let user choose file, then selecte data type based on file extension
supportedFileTypes = {'*.mpd';'*.tif'};
[handles.fileNameArbData,handles.fileDirectory,handles.fileExt] = uigetfile(supportedFileTypes,'open file - MpScan (*.mpd) or *.tif',handles.fileDirectory); % open file
if isequal(handles.fileExt,0)   % check to make sure a file was selected
    return
end

handles.fileExt = supportedFileTypes{handles.fileExt}(1,3:end);
cd (handles.fileDirectory);

switch handles.fileExt
    case 'mpd'
        
        % MATEO 20120313
        MATEO_MPD_NAME=fullfile (handles.fileDirectory,handles.fileNameArbData); display (MATEO_MPD_NAME)
        % END MATEO 20120313
        if isequal(handles.fileNameArbData,0)   % check to make sure a file was selected
            return
        end
        
        
        if ~strcmpi(handles.fileExt,'mpd')
            % not an .mpdf file
            errordlg('Oops - needs to be an .mpd (MpScope) file')
            return
        end
        
        set(handles.figure1,'Name',['pathAnalyzeGUI     ' handles.fileNameMat '     ' handles.fileNameArbData]);
        
        %         d =  mpdRead([handles.fileDirectory handles.fileNameMpd],'header');
        d =  mpdRead([handles.fileDirectory handles.fileNameArbData],'header');
        
        handles.dataMpd.Header = d.Header;
        
    case 'tif'
       
        if ~strcmpi(handles.fileExt,'tif')
            % not an .mpdf file
            errordlg('Oops - needs to be an .tif file')
            return
        end
         %we might to collect data such as mu/mV and fps (dt) from user.
        set(handles.figure1,'Name',['pathAnalyzeGUI     ' handles.fileNameMat '     ' handles.fileNameArbData]);
        thisFileInfo = imfinfo(fullfile(handles.fileDirectory,handles.fileNameArbData));
        handles.dataTif = struct('nRows',thisFileInfo(1).Height,'nCols',thisFileInfo(1).Width,'nFrames',numel(thisFileInfo));
    otherwise
        errordlg('Oops - unsopported data file, needs .mpd (MpScope) or tif file')
        return
end%switching file types
guidata(hObject, handles);

% --- BUTTON - Initialize
function pushButtonInitialize_Callback(hObject, eventdata, handles)


switch handles.fileExt
    case 'mpd'
        % load the first 100 lines, for an initial look
        handles.scanDataLines100 = ...
            mpdRead([handles.fileDirectory handles.fileNameArbData],'lines',handles.imageCh,1:100);
        
        figure(handles.figure1)    % return control to this figure, after the mpdRead
        
        % copy the selected channel into something useful for the program, so
        % it doesn't have to be selected specifically each time
        if handles.imageCh == 1
            handles.scanDataLines100.Im = handles.scanDataLines100.Ch1;
        elseif handles.imageCh == 2
            handles.scanDataLines100.Im = handles.scanDataLines100.Ch2;
        elseif handles.imageCh == 3
            handles.scanDataLines100.Im = handles.scanDataLines100.Ch3;
        elseif handles.imageCh == 4
            handles.scanDataLines100.Im = handles.scanDataLines100.Ch4;
        else
            error 'no channel selected'
        end
    case 'tif'
        handles.dataTif.subVol = struct('R',[1 100],'C',[1 handles.dataTif.nCols],'Z',[1 1]);
        handles.scanDataLines100.Im = flextiffread(fullfile(handles.fileDirectory,handles.fileNameArbData),...
            handles.dataTif.subVol);
        handles.scanDataLines100.xsize = handles.dataTif.nCols;
        handles.scanDataLines100.ysize = handles.dataTif.nRows;
        handles.scanDataLines100.num_frames = handles.dataTif.nFrames;

end %switching file types for loading 100 first lines

% take the 1d data as a projection of this (first 1000 lines)...
handles.scanResult1d = mean(handles.scanDataLines100.Im);   % average collapse to a single line
handles.scanResult1d = handles.scanResult1d(:);            % make a column vector

%%% sets up a bunch of things, once the data is loaded ...

% check to make sure data is loaded
if isempty( handles.scanResult1d )
    warndlg( 'oops, it appears that an arbScan data file was not loaded ...')
    return
end

if isempty( handles.scanData )
    warndlg( 'oops, it appears that a .mat (MATLAB) file was not loaded ...')
    return
end

sr1 = handles.scanResult1d;          % 'scan result 1d'
path = handles.scanData.path;        % 'scan path'

if size(sr1,1) ~= size(path,1)
    warndlg( 'oops - path length from matlab and MPD file do not match!')
    return
end

%%% populate listbox
strmat = [];

for s = 1:length(handles.scanData.scanCoords)
    strmat = strvcat(strmat,handles.scanData.scanCoords(s).name);
end
set(handles.listboxScanCoords,'String',cellstr(strmat));

% draw first frame, in axesSingleFrame
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
imagesc(handles.scanDataLines100.Im)
colormap('gray')
grid off

% draw a projection, in axesSingleFrameProjection
set(handles.figure1,'CurrentAxes',handles.axesSingleFrameProjection)
cla
plot(sr1)
colormap('gray')
set(gca,'xlim',[1 length(sr1)])

%PB - display region boundaries
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
nObj = max(handles.scanData.pathObjNum);
yLim = get(gca,'Ylim');
map = jet(nObj);
for iOBJ = 1 : nObj
    x = find(handles.scanData.pathObjNum==iOBJ);max(x)
    rectangle('Position', [x(1) yLim(1) x(end)-x(1) 5],'FaceColor',map(iOBJ,:));
end%creating objects
grid off


% make sure the dt in the .mat is the same as in the .MPD ...
% if they differ, just use the one in the MPD (if MPD file) or .dt from scanData if using tif
switch handles.fileExt
    case 'mpd'
if handles.scanDataLines100.Header.PixelClockSecs ~= handles.scanData.dt
    disp '... NOTE - dt differs in .MPD and .mat file, using the value in .MPD ... '
    handles.scanData.dt = handles.dataMpd.Header.PixelClockSecs;
end
    case 'tif'
      disp ' using the dt value in .mat ... '
        
end

handles.nPoints = handles.scanDataLines100.xsize ...
    * handles.scanDataLines100.ysize ...
    * handles.scanDataLines100.num_frames;

% total number of lines in scanned data
handles.nLines = handles.scanDataLines100.ysize ...
    * handles.scanDataLines100.num_frames;
handles.nPointsPerLine = handles.scanDataLines100.xsize;

handles.timePerLine = handles.nPointsPerLine * handles.scanData.dt;
%time_per_line_in_ms_for_display=handles.timePerLine*1000
%round minimum window duration (or time per line) to tenths of ms
set(handles.minWin,'String',...
    num2str(round(handles.timePerLine*1e4)/10));

% display some stuff for the user ...
clc
fprintf('%s',repmat('-',80,1));
disp(['  total scan time (s): ' num2str(handles.nPoints * handles.scanData.dt)])
disp(['  time per line (ms): ' num2str(handles.nPointsPerLine * handles.scanData.dt * 1000)])
disp(['  scan frequency (Hz): ' num2str(1 / (handles.nPointsPerLine * handles.scanData.dt))])
disp(['  distance between pixels (in ROIs) (mV): ' num2str(handles.scanData.scanVelocity *1e3)])
disp(['  time between pixels (us): ' num2str(1e6*handles.scanData.dt)])

disp ' '
disp '  initialize completed successfully '
% MATEO 20120313 To show the number of frames=total scan time/(time per
% line in sec)*512
% MATEO_NUMBER_OF_FRAMES=((handles.nPoints * handles.scanData.dt)/((handles.nPointsPerLine * handles.scanData.dt)*512))
% display (MATEO_NUMBER_OF_FRAMES)
% MATEO 20120313 To show the number of frames END

guidata(hObject, handles); % Update handles structure

% --- BUTTON - Draw Scan Path
function pushButtonDrawScanPath_Callback(hObject, eventdata, handles)
% check to make sure data was loaded
if isempty( handles.scanResult1d )
    warndlg( 'oops, it appears that a .mpd (MpScope) file was not loaded ...')
    return
end

if isempty( handles.scanData )
    warndlg( 'oops, it appears that a .mat (MATLAB) file was not loaded ...')
    return
end

sr1 = handles.scanResult1d;          % 'scan result 1d'
path = handles.scanData.path;        % 'scan path'

if size(sr1,1) ~= size(path,1)
    warndlg( 'oops - path length from matlab and MPD file do not match!')
    return
end

% plot the scan path here ...
set(handles.figure1,'CurrentAxes',handles.axesMainImage)
nPoints = size(path,1);
hold on

% scale the scan result for 0 to 1
sr1scaled = sr1;
sr1scaled = sr1scaled - min(sr1scaled);
sr1scaled = sr1scaled ./ max(sr1scaled);

%colormap(reverse(gray))
%colormap('default')
%colormap(gray);

%C = flipud(colormap);
%C = flipup(get(gca,'colormap'));
%colormap(C);
%set(gca,'colormap',C')

drawEveryPoints = 10;

set(handles.figure1,'CurrentAxes',handles.axesMainImage)

for i = 1:drawEveryPoints:nPoints      % skip points, if the user requests
    
    %color = hsv2rgb([i/nPoints,1,1]);
    %color = hsv2rgb([0,0,sr1scaled(i)]);        % plot intensity, black and white
    %color = [sr1scaled(i),0,0]                   % plot intensity as RED
    %color = [sr1scaled(i)/3 , sr1scaled(i) , sr1scaled(i)/3]                  % plot intensity as RED
    
    color = 'red';
    plot(path(i,1),path(i,2),'.','color',color)
    drawnow
end

% find the values from the image and the ideal path
nRows = size(handles.scanData.im,1);
nCols = size(handles.scanData.im,2);

sr1im = 0*sr1;      % will hold the scan result, scanning ideal path across image

% scale voltage coordinates to matrix coordinates
xMinV = handles.scanData.axisLimCol(1);
xMaxV = handles.scanData.axisLimCol(2);
yMinV = handles.scanData.axisLimRow(1);
yMaxV = handles.scanData.axisLimRow(2);

%% mjp commented out after feb 2011? try adding back in
% Ilya's corrections for scaling
%the +1 term is to account that we start at 1st pixel (not 0) but we end at
% nCol-1+1 pixel. Same for row. Checked with 512x512, 400x400, and 400x256
pathImCoords(:,1) = (nCols-1)*(path(:,1)-xMinV)/(xMaxV- xMinV)+1;
pathImCoords(:,2) = (nRows-1)*(path(:,2)-yMinV)/(yMaxV- yMinV)+1;

imMarked = handles.scanData.im;
markIntensity = max(imMarked(:)) * 1.1;

for i = 1:nPoints
    try
        c = round(pathImCoords(i,1));   %jd - note c comes before r!
        r = round(pathImCoords(i,2));
        
        imMarked(r,c) = markIntensity;
        
        sr1im(i) = handles.scanData.im(r,c);
    catch
        disp('Point out of bounds');
    end
end

% scale so that data from image matches data acquired from arbs scan ... generally not needed
sr1im = sr1im/mean(sr1im) * mean(sr1);

% plot some values

figure

plot( [sr1im sr1] )
legend('from image','from arb scan')

guidata(hObject, handles);         % Update handles structure (save the image)

pathImCoords(:,1) = path(:,1) * (nRows-1)/(xMaxV- xMinV) + 1 - (nRows-1)/(xMaxV - xMinV)*xMinV;
pathImCoords(:,2) = path(:,2) * (nCols-1)/(yMaxV- yMinV) + 1 - (nCols-1)/(yMaxV - yMinV)*yMinV;

imMarked = handles.scanData.im;
markIntensity = max(imMarked(:)) * 1.1;

for i = 1:nPoints
    c = round(pathImCoords(i,1));   %jd - note c comes before r!
    r = round(pathImCoords(i,2));
    if ~isnan(r);imMarked(r,c) = markIntensity;
        sr1im(i) = handles.scanData.im(r,c);
    end %nan in cropped files - by definitions PB
end

% scale so that data from image matches data acquired from arbs scan ... generally not needed
sr1im = sr1im/mean(sr1im) * mean(sr1);

% plot some values

%     figure % commented CM 20130627
%     subplot(2,2,1:2)
%     plot( [sr1im sr1] )
%     legend('from image','from arb scan')

guidata(hObject, handles);         % Update handles structure (save the image)


% --- BUTTON - Reset Image
function pushButtonResetImage_Callback(hObject, eventdata, handles)
if isempty( handles.scanData )
    warndlg( 'need to load a MATLAB file ...' )
    return
end

set(handles.figure1,'CurrentAxes',handles.axesMainImage)

cla
imagesc(handles.scanData.axisLimCol,handles.scanData.axisLimRow,handles.scanData.im);
axis on
axis tight
colormap('gray');
%     colormap('default');


% --- BUTTON - Rename
function pushButtonRename_Callback(hObject, eventdata, handles)
newName = inputdlg('type in new name (or enter to keep old name)');  % newName is a cell

if isempty(newName)
    return   % nothing to rename
end

elementIndex = get(handles.listboxScanCoords,'Value');
handles.scanData.scanCoords(elementIndex).name = newName{1};

%% populate listbox
strmat = [];
for s = 1:length(handles.scanData.scanCoords)
    strmat = strvcat(strmat,handles.scanData.scanCoords(s).name);
end
set(handles.listboxScanCoords,'String',cellstr(strmat));

guidata(hObject, handles);                                   % Update handles structure

% --- helper function, allows user to select other limits
function [userStartPoint userEndPoint] = selectLimit(handles,autoStartPoint,autoEndPoint)
% make sure the correct portion of the graph is selected, and draw
im = handles.scanDataLines100.Im;
figure(handles.figure1)
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
imagesc(im)
colormap('gray')
hold on
grid off

ymax = size(im,1);


%PB - display region boundaries
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
nObj = max(handles.scanData.pathObjNum);
yLim = get(gca,'Ylim');
map = jet(nObj);
for iOBJ = 1 : nObj
    x = find(handles.scanData.pathObjNum==iOBJ);max(x)
    rectangle('Position', [x(1) yLim(1) x(end)-x(1) 5],'FaceColor',map(iOBJ,:));
end%creating objects


%plot values from file (initial guess)
plot([autoStartPoint autoStartPoint],[1 ymax],'y')
plot([autoEndPoint autoEndPoint],[1 ymax],'y')

sp = ginput(1);    % get a user click, note sp(1) is distance across image
if( sp(1)<1 | sp(1)>size(im,2) | sp(2)<1 | sp(2)>size(im,1))
    userStartPoint = autoStartPoint;   % user clicked outside image, use default point
else
    userStartPoint = round(sp(1));            % use selected point
end

plot([userStartPoint userStartPoint],[1 ymax],'g')

ep = ginput(1);     % get a user click, note ep(1) is distance across image
if( ep(1)<1 | ep(1)>size(im,2) | ep(2)<1 | ep(2)>size(im,1))
    userEndPoint = autoEndPoint;     % user clicked outside image
else
    userEndPoint = round(ep(1));            % use selected point
end

plot([userEndPoint userEndPoint],[1 ymax],'r')
hold off


% --- BUTTON - Diameter Transform
function pushButtonDiameterTransform_Callback(hObject, eventdata, handles)
% Calculate the velocity, using the radon transform

elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element

% based on the item selected in the listbox, and the pathObjNum, find
% the start and end indices
allIndicesThisObject = find(handles.scanData.pathObjNum == elementIndex);
firstIndexThisObject = allIndicesThisObject(1);
lastIndexThisObject = allIndicesThisObject(end);

% let the user change the points, if desired
[firstIndexThisObject lastIndexThisObject] = ...
    selectLimit(handles,firstIndexThisObject,lastIndexThisObject);

dataStruct = struct( ...
    'fullFileNameArbData',[handles.fileDirectory handles.fileNameArbData], ...
    'firstIndexThisObject',firstIndexThisObject, ...
    'lastIndexThisObject',lastIndexThisObject, ...
    'assignName',handles.scanData.scanCoords(elementIndex).name, ...
    'windowSize',handles.windowSize, ...
    'windowStep',handles.windowStep,...
    'analysisType','diameter', ...
    'scanVelocity',handles.scanData.scanVelocity, ...
    'imageCh',handles.imageCh,...
    'dt',handles.scanData.dt);

if isfield(handles,'dataTif')
    dataStruct.dataTif = handles.dataTif;
    dataStruct.dt = handles.scanData.dt;
end



if handles.analyseLater
    writeForLater(dataStruct,handles);
else
    pathAnalysisHelper(dataStruct);
end

% --- Executes on button press in pushButtonIntensity.
function pushButtonIntensity_Callback(hObject, eventdata, handles)
% Calculate the velocity, using the radon transform

elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element

% based on the item selected in the listbox, and the pathObjNum, find
% the start and end indices
allIndicesThisObject = find(handles.scanData.pathObjNum == elementIndex);
firstIndexThisObject = allIndicesThisObject(1);
lastIndexThisObject = allIndicesThisObject(end);

% let the user change the points, if desired
if get(handles.allowResize,'Value')==1
    [firstIndexThisObject lastIndexThisObject] = ...
        selectLimit(handles,firstIndexThisObject,lastIndexThisObject);
end

dataStruct = struct( ...
    'fullFileNameArbData',[handles.fileDirectory handles.fileNameArbData], ...
    'firstIndexThisObject',firstIndexThisObject, ...
    'lastIndexThisObject',lastIndexThisObject, ...
    'assignName',handles.scanData.scanCoords(elementIndex).name, ...
    'windowSize',handles.windowSize, ...
    'windowStep',handles.windowStep,...
    'analysisType','intensity', ...
    'scanVelocity',handles.scanData.scanVelocity, ...
    'imageCh',handles.imageCh);

if isfield(handles,'dataTif')
    dataStruct.dataTif = handles.dataTif;
    dataStruct.dt = handles.scanData.dt;
end


if handles.analyseLater
    writeForLater(dataStruct,handles);
else
    pathAnalysisHelper(dataStruct);
end


% --- BUTTON - Radon Transform
function pushButtonRadonTransform_Callback(hObject, eventdata, handles)
% Calculate the velocity, using the radon transform

elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element

% based on the item selected in the listbox, and the pathObjNum, find
% the start and end indices
allIndicesThisObject = find(handles.scanData.pathObjNum == elementIndex);
firstIndexThisObject = allIndicesThisObject(1);
lastIndexThisObject = allIndicesThisObject(end);

% let the user change the points, if desired
[firstIndexThisObject lastIndexThisObject] = ...
    selectLimit(handles,firstIndexThisObject,lastIndexThisObject);

dataStruct = struct( ...
    'fullFileNameArbData',[handles.fileDirectory handles.fileNameArbData], ...
    'firstIndexThisObject',firstIndexThisObject, ...
    'lastIndexThisObject',lastIndexThisObject, ...
    'assignName',handles.scanData.scanCoords(elementIndex).name, ...
    'windowSize',handles.windowSize, ...
    'windowStep',handles.windowStep,...
    'analysisType','radon', ...
    'scanVelocity',handles.scanData.scanVelocity, ...
    'imageCh',handles.imageCh);

if isfield(handles,'dataTif')
    dataStruct.dataTif = handles.dataTif;
    dataStruct.dt = handles.scanData.dt;
end


if handles.analyseLater
    writeForLater(dataStruct,handles);
else
    pathAnalysisHelper(dataStruct);
end


% --- Executes on selection change in listboxScanCoords.
function listboxScanCoords_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns listboxScanCoords contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxScanCoords

%jd - doesn't really do anything now ...
% ... should have a check to see if data is loaded ...
elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element
handles.scanData.scanCoords(elementIndex);


% --- Executes during object creation, after setting all properties.
function listboxScanCoords_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- BUTTON - Draw Scan Regions
function pushButtonDrawScanRegions_Callback(hObject, eventdata, handles)
% note - this code is copied straight from pathGUI, could be a separate function ...
% plot the start and endpoints on the graph, and place text

for i = 1:length(handles.scanData.scanCoords)
    sc = handles.scanData.scanCoords(i);     % copy to a structure, to make it easier to access
    if strcmp(sc.scanShape,'blank')
        break                       % nothing to mark
    end
    
    % mark start and end point
    set(handles.figure1,'CurrentAxes',handles.axesMainImage)
    hold on
    
    plot(sc.startPoint(1),sc.startPoint(2),'g*')
    plot(sc.endPoint(1),sc.endPoint(2),'r*')
    
    % draw a line or box (depending on data structure type)
    if strcmp(sc.scanShape,'line')
        line([sc.startPoint(1) sc.endPoint(1)],[sc.startPoint(2) sc.endPoint(2)],'linewidth',2)
    elseif strcmp(sc.scanShape,'box')
        % width and height must be > 0 to draw a box
        boxXmin = min([sc.startPoint(1),sc.endPoint(1)]);
        boxXmax = max([sc.startPoint(1),sc.endPoint(1)]);
        boxYmin = min([sc.startPoint(2),sc.endPoint(2)]);
        boxYmax = max([sc.startPoint(2),sc.endPoint(2)]);
        
        rectangle('Position',[boxXmin,boxYmin, ...
            boxXmax-boxXmin,boxYmax-boxYmin], ...
            'EdgeColor','green');
    end
    
    % find a point to place text
    placePoint = sc.startPoint + .1*(sc.endPoint-sc.startPoint);
    text(placePoint(1)-.1,placePoint(2)+.05,sc.name,'color','red','FontSize',12)
    
end

colormap 'gray'



% --- BUTTON - Look ...
function pushButtonLook_Callback(hObject, eventdata, handles)
% take the radon transform, would need to call Patrick's code ...
elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element

% the data is held in:
%   handles.scanData.scanResult3d
% marks for what part of the path corresponds to what are in:
%   handles.scanData.pathObjNum

% for the item selected in the listbox, find the start and end indices, and cut out data

% find the indices of this scan object, subject to the constraint that the subObjectNum is non-zero
% subOjectNum being non-zero has no effect for lines, but will cut out turn regions for boxes
%indices = (handles.scanData.pathObjNum  == elementIndex & handles.scanData.pathObjSubNum > 0);
indices = (handles.scanData.pathObjNum  == elementIndex);

% cut out data, and image first frame ...
%lineData = handles.scanResult3d(:,firstIndexThisObject:lastIndexThisObject,1);
lineData = handles.scanResult3d(:,indices,1);

figure
subplot(4,2,1:4)
imagesc(lineData)

% image projection of first frame
subplot(4,2,5:6)
lineData = mean(lineData,1);
plot(lineData)
a = axis;
axis( [1 length(lineData) a(3) a(4)] )

% cut out only the sub-object portion, and plot this

% find the indices of this scan object, subject to the constraint that the subObjectNum is non-zero
% subOjectNum being non-zero has no effect for lines, but will cut out turn regions for boxes
%indices = (handles.scanData.pathObjNum  == elementIndex & handles.scanData.pathObjSubNum > 0);
indices = (handles.scanData.pathObjNum  == elementIndex & handles.scanData.pathObjSubNum > 0);

% cut out data, and image first frame ...
%lineData = handles.scanResult3d(:,firstIndexThisObject:lastIndexThisObject,1);
lineData = handles.scanResult3d(:,indices,1);

%
subplot(4,2,7:8)
lineData = mean(lineData,1);
plot(lineData)
a = axis;
axis( [1 length(lineData) a(3) a(4)] )



%--- EDIT (enter) - Window Size (in milliseconds)
function editWindowSizeMs_Callback(hObject, eventdata, handles)
handles.windowSize = 1e-3*str2double(get(hObject,'String'));  % store as seconds
guidata(hObject, handles);   % Update handles structure

% --- EDIT (creation) - Window Size (in milliseconds)
function editWindowSizeMs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editWindowSizeMs_Callback(hObject, eventdata, handles)   % execute, to read initial value


%--- EDIT (enter) - Window Step (in milliseconds)
function editWindowStepMs_Callback(hObject, eventdata, handles)
handles.windowStep = 1e-3*str2double(get(hObject,'String'));  % store as seconds
guidata(hObject, handles);   % Update handles structure


% --- EDIT (creation) - Window Step (in milliseconds)
function editWindowStepMs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editWindowStepMs_Callback(hObject, eventdata, handles)   % execute, to read initial value


% --- BUTTON - Analyse Stored Selections
function pushButtonAnalyseStoredSelections_Callback(hObject, eventdata, handles)
%implemented by PB
%the analyze later funcitonality creates an m file which generates an analysis object, run it first then execute 
evalin('base','clear all');
evalin('base',sprintf('run(''%s'')',fullfile(handles.fileDirectory,handles.analyseLaterFilename)))
evalin('base','pathAnalysisHelper(dataStructArray)')

% --- CHECKBOX - Queue Values (analyse later.
function checkboxQueueValues_Callback(hObject, eventdata, handles)
value = get(handles.checkboxQueueValues,'Value');

if value == true;
    c = clock;
    % elements are year, month, day, hour, minute, seconds
    s = '_'; % the space character, goes between the elements of the data
    c = [num2str(c(1)) s num2str(c(2)) s num2str(c(3)) s num2str(c(4)) s num2str(c(5)) s num2str(round(c(6)))];
    
    handles.analyseLaterFilename =  ['a' c '.m'];
    handles.analyseLater = true;
    
    % write the header info
    fid = fopen(handles.analyseLaterFilename,'a');
    
    % ... \% escape sequence does not work ... ?
    fprintf(fid,['%% analysis file for ' handles.fileNameMat ' ' handles.fileNameArbData '\n']);
    fprintf(fid,['%% created ' num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) '\n']);
    
    fprintf(fid,'dataStructArray = []; \n\n');
    fclose(fid);
else
    handles.analyseLater = false;
end

guidata(hObject, handles);   % Update handles structure

function writeForLater(dataStruct,handles)
% write this stuff to appropriate filename

fid = fopen(handles.analyseLaterFilename,'a');

escapedFilename = regexprep(dataStruct.fullFileNameArbData,'\\','\\\');  % changes \ to \\

fprintf(fid,'dataStruct = struct( ...\n');
fprintf(fid,[' ''fullFileNameArbData'',' '''' escapedFilename '''' ', ...\n'] ,'char');
fprintf(fid,[' ''firstIndexThisObject'',' '' num2str(dataStruct.firstIndexThisObject) '' ', ...\n'],'char');
fprintf(fid,[' ''lastIndexThisObject'',' '' num2str(dataStruct.lastIndexThisObject) '' ', ...\n'],'char');
fprintf(fid,[' ''assignName'',' '''' dataStruct.assignName '''' ', ...\n'],'char');
fprintf(fid,[' ''windowSize'',' num2str(dataStruct.windowSize) ', ...\n'],'char');
fprintf(fid,[' ''windowStep'',' num2str(dataStruct.windowStep) ', ...\n'],'char');
fprintf(fid,[' ''analysisType'',' '''' dataStruct.analysisType '''' ', ...\n'],'char');
fprintf(fid,[' ''scanVelocity'',' num2str(dataStruct.scanVelocity) ', ...\n'],'char');
fprintf(fid,[' ''imageCh'',' num2str(dataStruct.imageCh) ', ...\n'],'char');
fprintf(fid,[' ''dt'',' num2str(handles.scanData.dt) ' ...\n'],'char');

fprintf(fid,');\n');
%added by PB
fprintf(fid,'dataStruct.dataTif = struct(''nRows'',%d,''nCols'',%d,''nFrames'',%d);\n',handles.dataTif.nRows,handles.dataTif.nCols,handles.dataTif.nFrames);
fprintf(fid,'dataStruct.save2fileName = ''RES_%s'';\n',handles.fileNameMat);

fprintf('last=%s\tcurrent = %s\n',handles.analyseLaterLastLoadedMatFile,handles.fileNameMat);
if strcmp(handles.analyseLaterLastLoadedMatFile, handles.fileNameMat);
    %same file names means we didn't load a different data set so instruct helper to keep workspace variables
fprintf(fid,'dataStruct.cleanWorkspace = %d;\n',0);
else
    %different so helper needs to clean up before starting analysis, we also update last file flag
    handles.analyseLaterLastLoadedMatFile = handles.fileNameMat;
    fprintf(fid,'dataStruct.cleanWorkspace = %d;\n',1);

end
fprintf(fid,'dataStructArray = [dataStructArray dataStruct];\n');

fprintf(fid,'\n');

fclose(fid);
guidata(handles.figure1, handles);                                   % Update handles structure


% --- Executes on selection change in popUpChannel.
function popUpChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popUpChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popUpChannel contents as cell array
%        contents = get(hObject,'Value') returns selected item from popUpChannel
handles.imageCh = get(hObject,'Value');  % get current value (as a number by default)
guidata(hObject, handles); % Update handles structure

% --- Executes during object creation, after setting all properties.
function popUpChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popUpChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in allowResize.
function allowResize_Callback(hObject, eventdata, handles)
% hObject    handle to allowResize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_CropScan.
function pushbutton_CropScan_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CropScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%crop tif data to keep only linear portion of scan - 

cropLineSep_pxl = 10; %separate retion by this much
arbScanFullFileName =  fullfile(handles.fileDirectory,handles.fileNameArbData);
matFullFineName =  fullfile(handles.fileDirectory,handles.fileNameMat);
croppedTifFullFileName = [arbScanFullFileName(1:end-4) '-cropped' arbScanFullFileName(end-3:end)];
croppedArbScanMatFileName = [matFullFineName(1:end-4) '-cropped' matFullFineName(end-3:end)];


%%
switch handles.fileExt
    case 'mpd'
        warndlg('Inplemented for tif only files');
        return
    case 'tif'
        scanDataCrop = handles.scanData
        %figure out how many arb scan objects to keep AND their # of pixels
        nObj = max(handles.scanData.pathObjNum);
        objStart=zeros(nObj,1);
        objEnd=zeros(nObj,1);
        for iOBJ = 1 : nObj
            objStart(iOBJ) = find(handles.scanData.pathObjNum==iOBJ,1,'first');
            objEnd(iOBJ) = find(handles.scanData.pathObjNum==iOBJ,1,'last');
        end
        objNumPxl = objEnd - objStart + 1;
        %crop - number of columns is the only thing that changes
        croppedNumCol = sum(objNumPxl+cropLineSep_pxl*(nObj-1));
        croppedTif = zeros(handles.dataTif.nRows,croppedNumCol,handles.dataTif.nFrames,'uint16');
        scanDataCrop.pathObjNum = zeros(1,croppedNumCol);
        scanDataCrop.pathObjSubNum = zeros(1,croppedNumCol);
        scanDataCrop.path = NaN(croppedNumCol,2);
        pxlOffset = 0;
        for iOBJ = 1 : nObj
            croppedPxlIds = (1:objNumPxl(iOBJ))+pxlOffset;
            scanDataCrop.pathObjNum(croppedPxlIds) = handles.scanData.pathObjNum(objStart(iOBJ):objEnd(iOBJ));
            scanDataCrop.pathObjSubNum(croppedPxlIds) = handles.scanData.pathObjSubNum(objStart(iOBJ):objEnd(iOBJ));
            scanDataCrop.path(croppedPxlIds,:) = handles.scanData.path(objStart(iOBJ):objEnd(iOBJ),:);
            pxlOffset = croppedPxlIds(end) + cropLineSep_pxl;
            subVol = struct('R',[1 handles.dataTif.nRows],'C',[objStart(iOBJ) objEnd(iOBJ)],'Z',[1 handles.dataTif.nFrames]);
            croppedTif(:,croppedPxlIds,:) = flextiffread(arbScanFullFileName,subVol);
        end
           
end
%%

scanData = scanDataCrop;
save (croppedArbScanMatFileName,'scanData')
maketiff(croppedTif,croppedTifFullFileName);
