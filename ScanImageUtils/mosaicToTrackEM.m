% build layout.txt file for import into TrackEM (FIJI) from already created tile projections 
% very simple structure of each image (row in file): /path2image X Y Z (where Z is the layer), units are pixels

%define Mosaic parametes
path2TIF =  '/Users/pb/Data/PBLab/David/Leduq/20170227-RatPial_2/Ch_01';

%mosaic dimensions
nCols = 3;
nRows = 5;
colStep = 400;
rowStep = 400;
imgHeight = 512;
imgWidth = 512;

%for the current setting of motor in SI, the origin of the coordinate system for the mosaic is bottom-right: 
reverseCol = 1;
reverseRow = 1;

%filename string format
fNameStr = 'MAX_r001-R%02d-C%02d-Z01_00001.tif';

%% build grid
cPOS = 0:colStep:colStep*(nCols-1);
rPOS = (0:rowStep:rowStep*(nRows-1) )+ imgHeight;


colID = 1 : nCols;
rowID = 1 : nRows;

if reverseCol;colID = fliplr(colID);end
if reverseRow;rowID = fliplr(rowID);end

[rPosID, cPosID] = meshgrid(colID,rowID);
[rPos,cPos]=meshgrid(cPOS,rPOS);

%%
fid = fopen(fullfile(path2TIF,'layout.txt'),'w+');
nTiles = nCols * nRows;
for iTILE = 1 : nTiles
        fprintf(['%s%s' fNameStr '\t%f\t%f\t%d\n'],path2TIF,filesep,cPosID(iTILE),rPosID(iTILE),rPos(iTILE),cPos(iTILE),1);

    fprintf(fid,['%s%s' fNameStr '\t%f\t%f\t%d\n'],path2TIF,filesep,cPosID(iTILE),rPosID(iTILE),rPos(iTILE),cPos(iTILE),1);
    
end

fclose(fid)