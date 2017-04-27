function T = generateATdataTable(path2exp,path2TifFiles,expStructure)
%funciton generateATdataTable explore the directory tree of an AT experiments and based on the number of rows/cols per
%tissue slab, the number of channels and the number of tiles (data files) found, it returns a table containing the
%required information to generate a "layout" file for either exploring the data with trackEM or starting the aligment
%pipeline.
%
%   Inputs:
%       path2exp        - full path to root directory of experiment file
%       expStructre     - a structure describing the experiment acquisition details:
%               | nCyc               - scalar,  number of staining cycles
%               | nRibbons       - scalar, number of ribbons
%               | nCols             - scalar, number of columns in each tissue slab (rectangle)
%               | nRows            - scalar, number of rows in each tissue slab (rectangle)
%               | nSlabsInRibbon -  vector, number or tissue slabs in corresponding ribbon.
%               | colOffset_px      - scalar, offest between adjacent blocks along cols.
%               | rowOffset_pxl    - scalar, offest between adjacent blocks along rows.
%
%Current tree structure is as follows:
%   exp_ID
%           |-> CycID (CycXX) -                                      Cycle ID where XX is a [zero leading]  two digit from 01 to 99
%                       |->RID (RXXX)                                    Ribbon ID where XXX is a [zero leading] three digit from 001 to 999
%                                   |->_Tile_XXXXX_                   TIle folder where XXXXX is a [zero leading] five digit from 00001 to 99999
%                                       |->stack1                          CellCens (Olympus software) idiosyncrasy
%                                               |->frame_t_0.ets       CellCens (Olympus software) idiosyncrasy, the acutal data
%                                   |->Tile_XXXXX.vsi                 TIle header/description file matching the   _Tile_XXXXX_  folder name




%% Parse structure fields to variables, easier for coding...
expBaseName = expStructure.expBaseName;
nTilesInCol = expStructure.nCols;
nTilesInRow = expStructure.nRows;
nCyc = expStructure.nCyc;
nSlabsInRibbon = expStructure.nSlabsInRibbon;
colOffset_pxl = expStructure.colOffset_pxl;
rowOffset_pxl = expStructure.rowOffset_pxl;
nRibbons = expStructure.nRibbons;
nChannels = expStructure.nChannels;
alingement_ChNum = expStructure.alingement_ChNum;
ribbonNumbers = expStructure.ribbonNumbers;
%% recursively get all ets files, this will wrok also if ribbon hierarchy is not present.
fprintf('\nRecursively looking for ets files in directory....')
rDirContent = rdir([path2exp,'**/*.ets']);
fprintf('Done!');
%check that number of folders match number of expected tiles
nLayers = sum(nSlabsInRibbon); % each tissue slab represent a z-position or layer
nTilesInLayer = nTilesInCol * nTilesInRow;
expectedNumberOfTiles =  nTilesInLayer * nLayers * nCyc; % we expect COMPLETE experiments meaning the same number of ribbons/cycle

nDirs = numel(rDirContent);

if nDirs ~=expectedNumberOfTiles
    error('There are %d folders in "%s". It does not match the expected number of tiles (%d),', nDirs,path2exp,expectedNumberOfTiles)
end

%% Build table
%affine [ a0 a1 a2 a3 a4 a5] where [a0 a2 a3 a4] represent a unity matrix [1 0 0 1], (a2,a5) define the (col,row) position of the top left corner of each tile
fprintf('\nBuilding experiment layout table....')


cOffsets =(0: nTilesInCol-1).* colOffset_pxl;
rOffsets = (0:nTilesInRow-1).* rowOffset_pxl;
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
tmp=struct2cell(rDirContent(:));
pathToETS = tmp(1,:)';

% need to repeat position/blocks RCZ for cycles
rPos = repmat(rPos,nCyc,1);
cPos = repmat(cPos,nCyc,1);
Z = repmat(Z,nCyc,1);
R = repmat(R,nCyc,1);
C = repmat(C,nCyc,1);

Ribbon_ID = cell2mat(arrayfun(@(x,nx) repmat(x,1,nx),ribbonNumbers,nSlabsInRibbon.*nTilesInLayer ,'uniformoutput',0))';
Ribbon_ID = repmat(Ribbon_ID,nCyc,1);


%keep also track of each tile's ribbon and cycle
Cycle_ID = repmat(1:nCyc,nTilesInLayer * nLayers,1);
Cycle_ID = Cycle_ID(:);


T = table(rPos,cPos,Z,R,C,pathToETS,Cycle_ID,Ribbon_ID);
%prepare to append tiff file names - we keep only track of the DAPI channel used for alignment of the volumes (cycles).
%Then aligned volumes are co-aligned by  finding an affine transform (outside the alignment pipeline).

T.tileID = zeros(expectedNumberOfTiles,1);% and tile identifier, unique for each layer. will be 1000xR + C
%T.pathToETS = repmat({' ' },expectedNumberOfTiles,1);
T.pathToTIF = repmat({' ' },expectedNumberOfTiles,1);


%keep track of convertion progress by loggin flag into table
for iCH = 1 : nChannels
    cmd = sprintf('T.ch%d=zeros(%d,1);',iCH,expectedNumberOfTiles);
    eval(cmd);
end


for iD = 1 : size(T,1)
   % tileName = regexp(T.pathToETS{iD},'_Tile_(\d*)_','tokens'); %we extract the numers between _XXX_ form the folder name, expecting
   T.tileID(iD) = T.R(iD)*10000+T.C(iD);
    tifName = sprintf('%s_Cyc%02d_Rib%03d_Z%04d_R%03d_C%03d_Ch%02d.tif',expBaseName,Cycle_ID(iD),Ribbon_ID(iD),T.Z(iD),T.R(iD),T.C(iD),alingement_ChNum);
    T.pathToTIF(iD) ={fullfile(path2TifFiles, sprintf('Cyc%02d',T.Cycle_ID(iD)),tifName)};
    %fprintf(fid,'%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t-999\t-999\t0\t%s\n',T.Z(iD),T.tileID(iD),1,0,T.rPos(iD), 0, 1 ,T.cPos(iD),T.pathToTIF{iD});
end



fprintf('Done!');

