%cycle directory, load si-tiffs, split channels, offset to uint16  and save to each channel to tif  
path2source = '/Users/pb/Data/PBLab/David/Leduq/testingVIDA';
targetDir = fullfile(path2source,'ConvertedTifs'); 
nChannels = 1;
frameSize = [512 512];
% nSlices =  31;

%% create destination directoris if not present
if ~isdir(targetDir);mkdir(targetDir);end

%%
dirContent = dir([path2source filesep '*.tif']);
nFILES = numel(dirContent);
parfor iFILE = 1:nFILES
    %     obj = ScanImageTiffReader(fullfile(path2source,dirContent(iFILE).name)); 

    f= dirContent(iFILE).name;
    for iCH = 1 : nChannels
          %opting to use the opentif.m util (borrowed from +scanimge::+utils - note scanimage has to be in path.
        [~,stk]=opentif(fullfile(path2source,dirContent(iFILE).name),'channel',iCH);
        %opentif retuns a 5D file, redundant here so squeeze to get MxNxF where F is number of frames in stack
        stk = squeeze(stk);

        %find min value
        minVal = min(stk(:))
        if minVal<0
            stk=stk-minVal;
        end
        % convert to uint16
        stk = uint16(stk);
         [~,fBaseName]=fileparts(f);
         fTarget = fullfile(targetDir,sprintf('%s-Ch%d.tif',fBaseName,iCH));
         maketiff(stk,fTarget);
    end
end

%%


        