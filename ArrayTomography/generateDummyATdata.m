%simulate the data structure of AT experiments

targetDir = '/Users/pb/Data/PBLab/Shany/DummyData';
if isdir(targetDir)
    system(['rm -fr ' targetDir]);
end
mkdir(targetDir)

path2TifFiles = '/Users/pb/Data/PBLab/Shany/DummyData_tifs';
if isdir(path2TifFiles)
    system(['rm -fr ' path2TifFiles]);
end
mkdir(path2TifFiles)


%%
etsFileToCopy = '/Users/pb/Data/PBLab/Shany/AT\ R16/_R16-1.1_/stack1/frame_t_0.ets';
vsiFileToCopy = '/Users/pb/Data/PBLab/Shany/AT\ R16/R16-1.1.vsi';

%block mesh layout
nTilesInCol = 3;
nTilesInRow = 4;
nLayers = 3;

dirCreated = 0;
for iZ = 1 : nLayers
    for iCOL = 1 : nTilesInCol
        for iROW = 1 : nTilesInRow
            %geneate a directory branch with the following pattern "/_xxx_/stack1/frame_t_0.ets'
            
            tmp = sprintf('%s_%03d_%sstack1%sframe_t_0.ets',filesep,dirCreated,filesep,filesep);
            %create directory
            fullTargetPath = fullfile(targetDir,tmp);
            dir2create = fileparts(fullTargetPath);
            mkdir(dir2create)
            %copy ets
            cmd = sprintf('cp %s %s',etsFileToCopy,fullTargetPath);
            system(cmd);
            %copy vsi to base folder
            tmp = sprintf('%03d.vsi',dirCreated);
            %create directory
            fullTargetPath = fullfile(targetDir,tmp);
            cmd = sprintf('cp %s %s',vsiFileToCopy,fullTargetPath);
            system(cmd);
            
            dirCreated = dirCreated + 1;
        end
    end
end