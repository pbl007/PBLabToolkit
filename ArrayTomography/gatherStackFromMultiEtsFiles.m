path2dir = '/Volumes/Elements/AT/20170130_1.4_ R16_cyl1';
addpath('/Users/pb/Documents/Software/imreadBF_2')


experimentBaseName = 'AT_R16';
folderBaseName = 'R16-1.';
leafFolderName = 'stack1';
etsTargetFileName = 'frame_t_0.ets';
prefixFolderName = '_';
postfixFolderName = '_';

nStacksInEachFolder = 1;
nChannels = 4;

%dummy indices of row and column position, will be used in the future;
iR = 1;
iC = 1;
%% Get directory content, we expect here one "stack" file per dir

dirContent = dir([path2dir filesep])

%%
nTargetFolders = numel(dirContent);
for iCH = 1 : nChannels
    clear stack%
    for iFOLDER = 1 : 20
        iZ = iFOLDER; %not sure if always z=folder
        subPath = sprintf('%s%s%d%s%s',prefixFolderName,folderBaseName,iFOLDER,postfixFolderName, filesep, leafFolderName);
        path2ets =  fullfile( path2dir,subPath,etsTargetFileName);
        stack(:,:,iFOLDER)  = uint16(imreadBF(path2ets,1,1,iCH));
        tifTargetName = sprintf('%s-Z%03d-R%03d-C%03d-CH%02d.tif',experimentBaseName,iZ,iR,iC,iCH);
        path2tif =  fullfile( path2dir,subPath,tifTargetName);
        maketiff(uint16(stack(:,:,iFOLDER)),path2tif);
    end
    stackTargetName = fullfile(path2dir,(sprintf('%s-R%03d-C%03d-CH%02d.tif',experimentBaseName,iR,iC,iCH)))
    maketiff(stack,stackTargetName);
end
