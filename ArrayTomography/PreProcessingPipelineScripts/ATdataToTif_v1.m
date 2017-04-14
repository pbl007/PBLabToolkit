
%% ATdataToTif - 
% Walks through an AT data directory, converts ets data to tif and generates a 'layout' file as required for the 
% stitching pipeline.
% we assume for the moment that each ribbon is acquired wiht EXACTLY the same number of overlapping tiles, in a
% snake-like fashion, starting from the top-left corner (which is by convention the 0,0 coordinate). Since the number of
% tiles (and the col/row pattern) do not change, we can "guess" the layer organization given nBlocksInCol x nBlocksInRow
% etc. 

% Pablo - 20170131

%% Setup dataset structure
path2data = '/Volumes/AT/20170201_1p4_R16_Cyc2';
path2TifFiles = '/Volumes/AT/20170201_1p4_R16_Cyc2_tifs';

if ~isdir(path2tif);mkdir(path2tif);end


%block mesh layout
nTilesInCol = 5;
nTilesInRow = 9;
nLayers = 5;

%row/col offest in pixels
colOffset_pxl = 1490;
rowOffset_pxl = 1580;

%ets structure - usually no need to change anything below this line
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

%% Build table
%affine [ a0 a1 a2 a3 a4 a5] where [a0 a2 a3 a4] represent a unity matrix [1 0 0 1], (a2,a5) define the (col,row) position of the top left corner of each tile
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



%% generate layout.txt

fid = fopen(fullfile(path2tif,'layout.txt'),'w+');

% Z tileID a00 a01 a02 a10 a11 a12 col row cam full_path
T.tileID = zeros(expectedNumberOfTiles,1);% and tile identifier, unique for each layer. will be 1000xR + C
T.pathToTif = repmat({' ' },expectedNumberOfTiles,1);

for iD = 1 : expectedNumberOfTiles
    T.pathToTif(iD) ={ fullfile(path2tif,T.dirNames{iD},etsFolderName,etsFileName)};
    T.tileID(iD) = T.R(iD)*10000+T.C(iD);
    fprintf(fid,'%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t-999\t-999\t0\t%s\n',T.Z(iD),T.tileID(iD),1,0,T.rPos(iD), 0, 1 ,T.cPos(iD),T.pathToTif{iD});
end

fclose(fid)

%% convert to tif
iCH = 1
path2ets = fullfile(path2data,T.dirNames{iD},etsFolderName,etsFileName)
img = uint16(imreadBF(path2ets,1,1,iCH));