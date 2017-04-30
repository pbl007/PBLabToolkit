function batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels,varargin)
%batchDeinterleaveChannelsInSIfiles - deinterleave multichannel from SI tif files.
%
%Usage batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels) - will recursively search for tif files and attempt
%to deinterleave frames into 'nChannels'. 
%
%
% Dependencies - TIFFStack
% Pablo - Apr 2017
% Dependencies - TIFFStack, Enhanced_rdir, all appear in ../external
% Pablo - Apr 2017

%%
dirContent = rdir(fullfile(srcDir,'**/*.tif'));


%ensure destination exists
if ~isdir(destDir),mkdir(destDir);end

%% If the destination directory is inside the source and the conversion process is restarted, we want to avoid working on those files

valid = ~cellfun(@(x) (contains(x,destDir)),{dirContent.name});
dirContent=dirContent(valid);

%% deinterleave
nDirs = numel(dirContent);
fprintf('\nAbout to start processing %d',nDirs);


for iDIR = 1 : nDirs
   [~,thisFileBaseName]= fileparts(dirContent(iDIR).name);
    s = TIFFStack(dirContent(iDIR).name,[],nChannels);
    fprintf('\nProcessing file %d',iDIR);
    %process channels
    parfor_progress(nChannels);
    parfor iCH = 1 : nChannels
        fprintf('\t loading channel %d',iCH);
        thisChannelFileName = [thisFileBaseName sprintf('-Ch%d.tif',iCH)];
        %load channel and write tif
        tmp = squeeze(s(:,:,iCH,:));
        %SI tiffs are int16, we need to convert to uint16 by offsetting min value if <0 then casting to uint16
        minVal = min(tmp(:));
        if minVal<0;tmp=tmp-minVal;end
        fprintf('\t writting tif');
        maketiff(uint16(tmp),fullfile(destDir,thisChannelFileName));
    end
    
    parfor_progress;
end
parfor_progress(0);