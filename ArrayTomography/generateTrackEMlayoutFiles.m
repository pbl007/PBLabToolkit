function generateTrackEMlayoutFiles(T,expStructure,path2TifFiles)
% generateTrackEMlayoutFiles -converts data in table (from generateATdataTable) into a text file that TrackEM2 can input
% very simple structure of each image (row in file): /path2image X Y Z (where Z is the layer), units are pixels.
%
% Pablo

fprintf('\nGenerating TrackEM import files for each cycle...');
nCycles = expStructure.nCyc;

for iCYC = 1 : nCycles
    thisCycIDs = find(T.Cycle_ID==iCYC);
    
    fid = fopen(fullfile(path2TifFiles,sprintf('Cyc%02d_trackEM_import.txt',iCYC)),'w+');
    for iTER = 1:numel( thisCycIDs)
        iTILE = thisCycIDs(iTER);
        fprintf(fid,'%s\t%f\t%f\t%d\n',T.pathToTIF{iTILE},T.cPos(iTILE),T.rPos(iTILE),T.Z(iTILE));
        
    end
    fclose(fid);
end

fprintf('Done!')