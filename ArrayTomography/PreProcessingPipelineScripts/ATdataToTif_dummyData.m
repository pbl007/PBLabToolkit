
%% ATdataToTif -
% Walks through an AT data directory, converts ets data to tif and generates a 'layout' file as required for the
% stitching pipeline.
% we assume for the moment that each ribbon is acquired wiht EXACTLY the same number of overlapping tiles, in a
% snake-like fashion, starting from the top-left corner (which is by convention the 0,0 coordinate). Since the number of
% tiles (and the col/row pattern) do not change, we can "guess" the layer organization given nBlocksInCol x nBlocksInRow
% etc.

% Pablo - 20170131

%% Setup dataset structure
path2data = '/Users/pb/Data/PBLab/Shany/DummyData';
path2TifFiles = '/Users/pb/Data/PBLab/Shany/DummyData_tifs';

%the following define each experiment
animalIDStr = 'm300';
ribbonIDStr = '1p4';
cycleNumStr = '1';

%block mesh layout
nTilesInCol = 3;
nTilesInRow = 4;
nLayers = 3;

%row/col offest in pixels
colOffset_pxl = 1490;
rowOffset_pxl = 1580;
um_per_pixel = [];
%DAPI channel #
alingement_ChNum = 1;
nChannels = 4;

%% ets structure - usually no need to change anything below this line, so do not :-)
etsFileName = 'frame_t_0.ets';
etsFolderName = 'stack1';

%% Get directory content, filter out system-reserved directories

dirContent = dir(path2data);
dirContent = dirContent([dirContent.isdir]); %remove non-direcory entries

nDirs = numel(dirContent);
valid = zeros(nDirs,1,'like',true);
for iDIR= 1 : nDirs
    %keep directories without "." in the name (reserved for system directories such as ".", ".." and similar
    valid(iDIR)=~contains(dirContent(iDIR).name,'.');
end

dirContent=dirContent(valid);
%check that number of folders match number of expected tiles
nTilesInLayer = nTilesInCol * nTilesInRow;
expectedNumberOfTiles =  nTilesInLayer * nLayers;

nDirs = numel(dirContent);

if nDirs ~=expectedNumberOfTiles
    error('There are %d folders in "%s". It does not match the expected number of tiles (%d),', nDirs,path2data,expectedNumberOfTiles)
end

%% Build table, it easy to get all variables in one place.
cOffsets = [0: nTilesInCol-1].* colOffset_pxl;
rOffsets = [0:nTilesInRow-1].* rowOffset_pxl;
[rPos,cPos]=meshgrid(rOffsets,cOffsets);

%construct basic layer layout
cNum = 1 : nTilesInCol;
rNum = 1 : nTilesInRow;
[R,C]=meshgrid(rNum,cNum);

%apply snake transform to column
C(:,2:2:end) = flipud(C(:,2:2:end));
cPos(:,2:2:end) = flipud(cPos(:,2:2:end));

%transform into column vectors
R=R(:);
C=C(:);
rPos=rPos(:);
cPos=cPos(:);

%repeat layout x number of layers
Z = repmat(1:nLayers,nTilesInLayer,1);
Z=Z(:);
R = repmat(R,nLayers,1);
C = repmat(C,nLayers,1);
cPos = repmat(cPos,nLayers,1);
rPos = repmat(rPos,nLayers,1);

% prepare dir names to enter into table
tmp=struct2cell(dirContent(:));
dirNames = tmp(1,:)';


T = table(rPos,cPos,Z,R,C,dirNames);
T.tileID = zeros(expectedNumberOfTiles,1);% and tile identifier, unique for each layer. will be 1000xR + C
T.pathToETS = repmat({' ' },expectedNumberOfTiles,1);
T.pathToTIF = repmat({' ' },expectedNumberOfTiles,1);


%keep track of convertion progress by loggin flag into table
for iCH = 1 : nChannels
    cmd = sprintf('T.ch%d=zeros(%d,1)',iCH,expectedNumberOfTiles);
    eval(cmd)
end


%% generate layout.txt - the layout for the aligment is based on the DAPI channel so it is the only one logged into the table
%affine [ a0 a1 a2 a3 a4 a5] where [a0 a2 a3 a4] represent a unity matrix [1 0 0 1], (a2,a5) define the (col,row) position of the top left corner of each tile

fid = fopen(fullfile(path2TifFiles,'layout.txt'),'w+');

% Z tileID a00 a01 a02 a10 a11 a12 col row cam full_path


for iD = 1 : expectedNumberOfTiles
    T.pathToETS(iD) ={ fullfile(path2TifFiles,T.dirNames{iD},etsFolderName,etsFileName)};
    tileName = T.dirNames{iD}(regexp(T.dirNames{iD},'[0-9]')); %we extract the numers between _XXX_ form the folder name
    tifName = sprintf('%s_%s_%s_Z%04d_R%03d_C%03d_Ch%02d.tif',animalIDStr,cycleNumStr,ribbonIDStr,T.Z(iD),T.R(iD),T.C(iD),alingement_ChNum);
    T.pathToTIF(iD) ={fullfile(path2TifFiles, tifName)};
    
    T.tileID(iD) = T.R(iD)*10000+T.C(iD);
    fprintf(fid,'%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t-999\t-999\t0\t%s\n',T.Z(iD),T.tileID(iD),1,0,T.rPos(iD), 0, 1 ,T.cPos(iD),T.pathToTIF{iD});
end

fclose(fid);

%% convert to tif - input in only based on table entries + numChannel
if ~isdir(path2TifFiles);mkdir(path2TifFiles);end

nTasks = size(T,1);
taskProgress = zeros(nTasks,nChannels); %keep status tab

parfor iTASK = 1 : nTasks
    for iCH = 1 : nChannels
        %read
        
        %build tif name
        tileName = T.dirNames{iTASK}(regexp(T.dirNames{iTASK},'[0-9]')); %we extract the numers between _XXX_ form the folder name
        tifName = sprintf('%s_%s_%s_Z%04d_R%03d_C%03d_Ch%02d.tif',animalIDStr,cycleNumStr,ribbonIDStr,T.Z(iTASK),T.R(iTASK),T.C(iTASK),iTASK);
        path2tif = fullfile(path2TifFiles,tifName);
        
        try
            path2ets = fullfile(path2data,T.dirNames{iTASK},etsFolderName,etsFileName);
            img = uint16(imreadBF(path2ets,1,1,iCH));
            maketiff(img,path2tif);
            %log successful
            status = 1;
        catch
            %log failure
            status = -1;
        end
        taskProgress(iTASK,iCH)=status;
        T
    end
end

%update progress table (can't be done inside parfor...)
for iCH = 1 : nChannels
    cmd = sprintf('T.ch%d(:)=taskProgress(:,%d);',iCH,iCH);
    eval(cmd)
end