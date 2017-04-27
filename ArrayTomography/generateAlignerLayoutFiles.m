function generateAlignerLayoutFiles(T,expStructure,path2TifFiles)
% generateTrackEMlayoutFiles -converts data in table (from generateATdataTable) into a text file that TrackEM2 can input
% very simple structure of each image (row in file): /path2image X Y Z (where Z is the layer), units are pixels.
%
% Pablo

fprintf('\nGenerating Aligner layout files for each cycle...');
nCycles = expStructure.nCyc;

for iCYC = 1 : nCycles
    thisCycIDs = find(T.Cycle_ID==iCYC);
    
    fid = fopen(fullfile(path2TifFiles,sprintf('Cyc%02d_layoutt.txt',iCYC)),'w+');
    for iTER = 1:numel( thisCycIDs)
        iD = thisCycIDs(iTER);
        fprintf(fid,'%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t-999\t-999\t0\t%s\n',T.Z(iD),T.tileID(iD),1,0,T.rPos(iD), 0, 1 ,T.cPos(iD),T.pathToTIF{iD});
        
    end
    fclose(fid);
end

fprintf('Done!')