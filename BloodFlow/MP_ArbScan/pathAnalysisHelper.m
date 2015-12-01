function pathAnalysisHelper(analysisObject)

% Stand-alone function for calculating the diameter, intensity, and radon
% of .mpd data from two photon scanning
% program is a helper function of arbitrary scan and associated programs
% (PathGUI, PathAnalysisGUI, etc.)
% the analysisObject is a datastructure, specifying the
% information needed to do an analysis
%
% Supports working wiht both tif and mpd
% Speed up calculation -if possible using gpu or parfor-
% Last updated 21-11-2015 - Pablo Blinder

if length(analysisObject) > 1
    % array was passed in, loop through this, then return
    for i = 1:length(analysisObject)
        pathAnalysisHelper(analysisObject(i));
    end
    return;
end

useGPU = gpuDeviceCount;

%% analysisObject has the following elements:

fileNameArbData      = analysisObject.fullFileNameArbData;
firstIndexThisObject = analysisObject.firstIndexThisObject;
lastIndexThisObject  = analysisObject.lastIndexThisObject;
assignName           = analysisObject.assignName;
windowSize           = analysisObject.windowSize;
windowStep           = analysisObject.windowStep;
analysisType         = analysisObject.analysisType;
imageCh              = analysisObject.imageCh;

[~,~,fileExt] = fileparts(fileNameArbData);
dataType = fileExt(2:end);


assignName(assignName == ' ') = '_';       % change spaces to underscores

%scanVelocity = analysisObject.scanVelocity; % only use if needed

%% get the first 1000 lines, and associated info
disp(num2str(imageCh))
switch dataType
    case 'mpd'
        scanDataLinesK = mpdRead(fileNameArbData,'lines',imageCh,1:1000);
        dt = scanDataLinesK.Header.PixelClockSecs;                    % pixel clock
        if imageCh == 1
            scanResult1d = mean(scanDataLinesK.Ch1);   % average collapse to a single line
        elseif imageCh == 2
            scanResult1d = mean(scanDataLinesK.Ch2);   % average collapse to a single line
        elseif imageCh == 3
            scanResult1d = mean(scanDataLinesK.Ch3);   % average collapse to a single line
        elseif imageCh == 4
            scanResult1d = mean(scanDataLinesK.Ch4);   % average collapse to a single line
        end
    case 'tif'
        %dealing with tif data
        dataTif = analysisObject.dataTif;
        dt = analysisObject.dt;
        scanDataLinesK.xsize = dataTif.nCols;
        scanDataLinesK.num_frames = dataTif.nFrames;
        scanDataLinesK.ysize = dataTif.nRows;
        %get first frame - needed for setting some defaults down the road
        dataTif.subVol = struct('R',[1 dataTif.nRows],'C',[1 dataTif.nCols],'Z',[1 2]);
        scanDataLinesK.Ch1 = flextiffread(fileNameArbData,dataTif.subVol);
        scanResult1d = mean(scanDataLinesK.Ch1);
end
%%
nPointsPerLine = scanDataLinesK.xsize;                        % points (pixels) each scan line
nLines = scanDataLinesK.num_frames * scanDataLinesK.ysize;    % total number of lines in data
timePerLine = nPointsPerLine * dt;                            % time spent scanning each line

% numbers for conversions ...
%   secondsPerRow is the time it takes to scan each line,
%   mvPerCol is the pixel spacing over scan regions, in millivolts
secsPerRow = timePerLine;                                 % in seconds
mvPerCol = (analysisObject.scanVelocity) * 1e3;           % in mV

scanResult1d = scanResult1d(:);            % make a column vector

%% setup specific to different kinds of analysis, need to set up all for parfor to work

%diameter
    typicalDiam = scanResult1d(firstIndexThisObject:lastIndexThisObject);
    offset = min(typicalDiam);                           % find the baseline
    threshold = max(typicalDiam - offset) / 2 + offset;  % threshold is half max, taking offset into account
    
    smoothing = 3;          % smooth data before taking width ...
    
    %radon
thetaRange = 0:179;
thetaAccuracy = .05;

%intensity - nothing really



%% loop through data, creating blocks to analyse

nLinesPerBlock = round(windowSize / (nPointsPerLine * dt));   % how many lines in each block?

windowStartPoints = round(1:windowStep / (nPointsPerLine * dt) : nLines-nLinesPerBlock);  % where do the windows start (in points?)

%%
% cut down the window
%jdd - shorten the analysis, for testing
%windowStartPoints = windowStartPoints(1:100);

analysisData = 0*windowStartPoints;      % create space to hold data
analysisDataSep = analysisData;          % holds the separation (only needed for Radon)

disp(['calculating ' analysisType '(displaying percent done) ...'])
%%
% loop through the data, calculating relevant variable
parfor i = 1:length(windowStartPoints)
    if ~mod(i,round(length(windowStartPoints)/50))
        disp(['  ' num2str(round(100*i/length(windowStartPoints))) ' %'])
    end
    
    w = windowStartPoints(i);         % which line to start this window?
    switch dataType
        case 'mpd'
            % passing 'true' as the last line keeps the activeX from being re-opened
            blockData = mpdRead(fileNameArbData,'lines',imageCh, ...
                w:w-1+nLinesPerBlock,true);
            
            %    blockDataMean = mean(blockData.Ch1,1);      % take mean of several frames
            if imageCh == 1
                blockDataMean = mean(blockData.Ch1,1);   % take mean of several frames imageCh == 1
            elseif imageCh == 2
                blockDataMean = mean(blockData.Ch2,1);   % take mean of several frames imageCh == 2
            elseif imageCh == 3
                blockDataMean = mean(blockData.Ch3,1);   % take mean of several frames imageCh == 3
            elseif imageCh == 4
                blockDataMean = mean(blockData.Ch4,1);   % take mean of several frames imageCh == 4
            end
            
            %     blockDataMean = blockDataMean(firstIndexThisObject:lastIndexThisObject);  % cut out only portion for this object
            
            %blockDataCut = blockData.Ch1(:,firstIndexThisObject:lastIndexThisObject);
            if imageCh == 1
                blockDataCut = blockData.Ch1(:,firstIndexThisObject:lastIndexThisObject);
            elseif imageCh == 2
                blockDataCut = blockData.Ch2(:,firstIndexThisObject:lastIndexThisObject);
            elseif imageCh == 3
                blockDataCut = blockData.Ch3(:,firstIndexThisObject:lastIndexThisObject);
            elseif imageCh == 4
                blockDataCut = blockData.Ch4(:,firstIndexThisObject:lastIndexThisObject);
            end
            %jdd
            %if i==1
            %    assignin('base','b1',blockDataCut);
            %    return
            %end
        case 'tif'
            blockData = flextiffread(fileNameArbData, [w w-1+nLinesPerBlock]);
            %            fprintf('\n%d\t%d\t%d',i,w,size(blockData,1));
            blockDataCut=blockData(:,firstIndexThisObject:lastIndexThisObject);
            
    end
    blockDataMean = mean(blockDataCut);
    if strcmp(analysisType,'diameter')
        analysisData(i) = calcFWHM(blockDataMean,smoothing,threshold,0);%gpu doesn't really spead up things here
    elseif strcmp(analysisType,'intensity')
        analysisData(i) = mean(blockDataMean);
    elseif strcmp(analysisType,'radon')
        [theta sep] = radonBlockToTheta(blockDataCut,thetaAccuracy,thetaRange);
        analysisData(i) = theta;
        analysisDataSep(i) = sep;
        % look around previous value for theta
        % this speeds things up, but can also cause the data to "hang"
        % on incorrect values
        %thetaRange = [theta-10:theta+10];
    end
end

%% post-processing, if necessary

%here we assign variable to the base workspace. Check if we need to clean up workspace before hand, needed to save to
%separated files in multi datasets called from "analyze later"

if isfield(analysisObject,'cleanWorkspace')
   if analysisObject.cleanWorkspace
       evalin('base','clear all')
   end
end

if strcmp(analysisType,'radon')
    % convert this to a more usable form
    %   (timePerLine) holds vertical spacing info
    %   (scanVelocity*1e3) is distance between pixels (in ROIs), in mV
    % note that theta is actually reported angle from vertical, so
    %    vertical lines (stalls) have theta of zero
    %    horizontal lines (very fast) have theta of 90
    %    (angle is measured ccw from vertical)
    %
    %            cols    mvPerCol     row          mv
    %  tand() =  ---- * --------  * ----------  =  ---
    %            row      col       secsPerRow     sec
    %
    % the units of mv/sec can be converterd into a speed by noting that mv
    % corresponds to a distance
    
    speedData = (tand(analysisData)) * mvPerCol / secsPerRow;    % note this is taken in degrees
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_radon_mv_per_s'],speedData);   % mv / second
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_radon_theta'],analysisData);   % degrees from vertical
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_radon_sep'],analysisDataSep);   % degrees from vertical
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_radon_um_per_s'],speedData*analysisObject.um2mv);   % um / second

elseif strcmp(analysisType,'diameter')
    analysisData = analysisData * mvPerCol;     % convert units (currently in pixels) to millivolts
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_diameter_mv'],analysisData);   % mv / second
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_diameter_um'],analysisData*analysisObject.um2mv);   % um / second

else
    % other analysis, besides radon or diameter (i.e., intensity)
    assignName(assignName == ' ') = '_';                           % change spaces to underscores
    assignin('base',[assignName '_' 'ch' num2str(imageCh) '_' analysisType],analysisData);
end

disp ' ... done'

% make a time axis that matcheds the diameter info
time_axis = windowSize/2 + windowStep*(0:length(analysisData)-1);
assignin('base',[assignName '_time_axis'],time_axis);

%% check if need to store results in file - used when processing multiple request from "analyze later" in pathAnalyzeGui
if isfield (analysisObject ,'save2fileName')
    cmd = sprintf('save(''%s'')',analysisObject.save2fileName);
    evalin('base',cmd);
end

%%
% finally, made sure the hidden file (opened when the analysis was run)
if strcmp(dataType,'mpd')
    mpdRead(fileNameArbData,'header');
    close(gcf)
    pause(.001);  % short pause is needed to show the variables that were put on the base space
end
