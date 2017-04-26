%cycle directory, load si-tiffs, split channels and save a max projection for each.

path2source = 'c/Volumes/Data/Julia/02022017M01-Prv';
nChannels = 3;
frameSize = [512 512];
% nSlices =  31;

%% create destination directoris if not present
targetDir = cell(nChannels,1);
for iCH =1 : nChannels
    targetDir{iCH} = fullfile( path2source,sprintf('Ch_%02d',iCH));
    if ~isdir(targetDir{iCH})
        mkdir(targetDir{iCH});
    end
        
end

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
        thisMaxProjName = sprintf('MAX_%s',dirContent(iFILE).name);
%         thisProj = max(stk(:,:,15:25),[],3);
        thisProj = sum(stk,3)-double(median(stk,3));
        maketiff(uint16(thisProj),fullfile(targetDir{iCH},thisMaxProjName));   
    end
end