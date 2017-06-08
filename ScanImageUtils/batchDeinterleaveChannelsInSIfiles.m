function batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels,varargin)
%batchDeinterleaveChannelsInSIfiles - deinterleave multichannel from SI tif files.
%
%Usage batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels) - will recursively search for tif files and attempt
%to deinterleave frames into 'nChannels'. 
%
%
% Dependencies - TIFFStack
% Pablo - Apr 2017
% Dependencies - TIFFStack, Enhanced_rdir, parfor_progress, all appear in ../external
% Pablo - Apr 2017
 
%%
addpath(genpath('/data/MatlabCode/PBLabToolkit/External/TIFFStack'));
addpath(genpath('/data/MatlabCode/PBLabToolkit/External/Enhanced_rdir'));
addpath(genpath('/data/MatlabCode/PBLabToolkit/External/parfor_progress'));
dirContent = rdir(fullfile(srcDir,'**/*.tif'));

if nargin>3
    params = varargin{1};
else 
    params.frames2use = []; % cell array (same numel as number of channels) specifying frames to average
    params.deltaFrames = []; % number of frames per actual slice (several where acquired but we want to keep the average of a subset).
end

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
    fprintf('\nProcessing file %d\n',iDIR);
    %process channels
    parfor_progress(nChannels);
    parfor iCH = 1 : nChannels
        fprintf('loading channel %d ',iCH);
        thisChannelFileName = [thisFileBaseName sprintf('-Ch%d.tif',iCH)];
        %load channel and write tif
        tmp = squeeze(s(:,:,iCH,:));
        if ~isempty( params.frames2use)
            avgFrames = params.frames2use{iCH};
            deltaFrames = params.deltaFrames;
            nZ =  size(tmp,3);
            if mod(nZ,deltaFrames)~=0;error('Number of frames in slide does not match stack size');end
            
            nFramesInFinalStack =nZ/deltaFrames;
            [nR, nC, ~] = size(tmp);
            tmp2 = zeros(nR,nC,nFramesInFinalStack,'int16');
            fprintf('\t Averaging frames');
            for iZ = 1 : nFramesInFinalStack
                tmp2(:,:,iZ) =  mean(tmp(:,:,(avgFrames + (iZ - 1) * deltaFrames)),3);
            end
            tmp = tmp2;
        end
        
        %SI tiffs are int16, we need to convert to uint16 by offsetting min value if <0 then casting to uint16
        minVal = min(tmp(:));
        if minVal<0;tmp=tmp-minVal;end
        fprintf('\t writing tif');
        maketiff(uint16(tmp),fullfile(destDir,thisChannelFileName));
    end
    
    parfor_progress;
end
%parfor_progress(0);