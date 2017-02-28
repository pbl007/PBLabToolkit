% layerToTrackEMtxt -converts data in table (from ATdataToTif) into a text file that TrackEM2 can input
% very simple structure of each image (row in file): /path2image X Y Z (where Z is the layer), units are pixels

nTiles = size(T,1)

for iTILE = 1 : nTiles
    
    fprintf('%s\t%f\t%f\t%d\n',T.pathToTIF{iTILE},T.cPos(iTILE),T.rPos(iTILE),T.Z(iTILE));
    
end