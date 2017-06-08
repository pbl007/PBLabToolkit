function cropArbScan(matFullFileName,arbScanFullFileName,options)
% cropArbScan - reduce tif file size by keeping only the linear portion of the arbscans (i.e. the objects). This is
% particularly useful for very long scans
%
%
% Pablo Blinder - 2015-Nov-22

%% HARDCODED DEF
cropLineSep_pxl = 10; %separate retion by this much

ChPosStr = regexp(arbScanFullFileName,'-Ch\d.tif');
croppedTifFullFileName = [arbScanFullFileName(1:ChPosStr-1) '-cropped' arbScanFullFileName(ChPosStr:end)];
croppedArbScanMatFileName = [matFullFileName(1:end-4) '-cropped' matFullFileName(end-3:end)];

%% load data
load(matFullFileName,'scanData')
scanDataCrop = scanData;
thisFileInfo = imfinfo(arbScanFullFileName);
dataTif = struct('nRows',thisFileInfo(1).Height,'nCols',thisFileInfo(1).Width,'nFrames',numel(thisFileInfo));


%% keep original path period 
scanDataCrop.isCropped = 1;%flag downstream functions explicitly
scanDataCrop.pathPeriod_s = scanData.dt * numel(scanData.pathObjNum);
scanDataCrop.oriPathLen = size(scanData.path,1);
scanDataCrop.Note = 'Scan period computed as number of points in original path times dt';

%figure out how many arb scan objects to keep AND their # of pixels
nObj = max(scanData.pathObjNum);
objStart=zeros(nObj,1);
objEnd=zeros(nObj,1);
for iOBJ = 1 : nObj
    objStart(iOBJ) = find(scanData.pathObjNum==iOBJ,1,'first');
    objEnd(iOBJ) = find(scanData.pathObjNum==iOBJ,1,'last');
end
objNumPxl = objEnd - objStart + 1;
%crop - number of columns is the only thing that changes
croppedNumCol = sum(objNumPxl)+cropLineSep_pxl*(nObj-1);
croppedTif = zeros(dataTif.nRows,croppedNumCol,dataTif.nFrames,'uint16');
scanDataCrop.pathObjNum = zeros(1,croppedNumCol);
scanDataCrop.pathObjSubNum = zeros(1,croppedNumCol);
scanDataCrop.path = NaN(croppedNumCol,2);
pxlOffset = 0;
for iOBJ = 1 : nObj
    croppedPxlIds = (1:objNumPxl(iOBJ))+pxlOffset;
    scanDataCrop.pathObjNum(croppedPxlIds) = scanData.pathObjNum(objStart(iOBJ):objEnd(iOBJ));
    scanDataCrop.pathObjSubNum(croppedPxlIds) = scanData.pathObjSubNum(objStart(iOBJ):objEnd(iOBJ));
    scanDataCrop.path(croppedPxlIds,:) = scanData.path(objStart(iOBJ):objEnd(iOBJ),:);
    pxlOffset = croppedPxlIds(end) + cropLineSep_pxl;
    subVol = struct('R',[1 dataTif.nRows],'C',[objStart(iOBJ) objEnd(iOBJ)],'Z',[1 dataTif.nFrames]);
    croppedTif(:,croppedPxlIds,:) = flextiffread(arbScanFullFileName,subVol);
end

%%
scanData = scanDataCrop;
if options.doUpdateTifName
    strPos = regexp(croppedTifFullFileName,'\w-cropped');
    croppedTifFullFileName=[matFullFileName(1:end-4) croppedTifFullFileName(strPos+1:end)];
end
save (croppedArbScanMatFileName,'scanData')
maketiff(croppedTif,croppedTifFullFileName);

%% generate thumb
if options.doMakeThumb
    
    figure('name',croppedArbScanMatFileName)
    subplot(1,2,1)
    h2a1 = gca;
    imagesc(scanData.axisLimCol,scanData.axisLimRow,scanData.im);
    axis image
    colormap gray
    
    subplot(1,2,2)
    h2a2 = gca;
    imagesc(croppedTif(:,:,1))
    
    nObj = max(scanData.pathObjNum);
    yLim = get(gca,'Ylim');
    map = jet(nObj);
    for iOBJ = 1 : nObj
        x = find(scanData.pathObjNum==iOBJ);max(x)
        axes(h2a2)
        rectangle('Position', [x(1) yLim(1) x(end)-x(1) 20],'FaceColor',map(iOBJ,:));
        
        %add scan coordinates
        axes(h2a1)
        sc = scanData.scanCoords(iOBJ);     % copy to a structure, to make it easier to access
        if strcmp(sc.scanShape,'blank')
            break                       % nothing to mark
        end
        
        % mark start and end point
        hold on
        
        plot(sc.startPoint(1),sc.startPoint(2),'g*')
        plot(sc.endPoint(1),sc.endPoint(2),'r*')
        
        % draw a line or box (depending on data structure type)
        if strcmp(sc.scanShape,'line')
            line([sc.startPoint(1) sc.endPoint(1)],[sc.startPoint(2) sc.endPoint(2)],'linewidth',2,'Color',map(iOBJ,:),'linestyle',':')
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
        
    end%creating objects
    
    thumbFileName = croppedArbScanMatFileName(1:end-4);
    export_fig (thumbFileName);
end

