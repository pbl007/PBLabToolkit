function prmts = MosaicTiling_getMosaicLayout(prmts)
% mosaicLayout is an r by c matrix where r and c are the largest row and columns index
% found in the dataset. 1 is for occumpancy, 0 for empty
% For mpd files, function computes the stage offsets from the expected grid
% position and save to mat file. For tiff files, function looks for stage
% error mat file and loads it.
%
% TODO : 1) extract from MPDs and apply stage errors
%
%Pablo 06Jul2010 

%%
task = 'Exploring Mosaic Layout';
fprintf('\n%s',repmat('*',60,1));
fprintf('\n%s',task);
t0 = clock;

generateDummyError = 0; % will attempt to use existing stage postions from file for tiffs

path2dir = prmts.path2dir;
dirContent = dir([path2dir filesep '*.' prmts.fileTypeToUse]);
nCandidateFilesInFolder = numel(dirContent);
baseName = prmts.baseName;
channel = num2str(prmts.xcorrCh);
%filenames pattern is basename-Zxx-Cxx-Rxx-Chx.tif
%cycle dir content and determine max Z,C and R for Z01 as mosaic is constant across
%zpositions

ZstrPos = numel(baseName) + 2;
CstrPos = ZstrPos + 4;
RstrPos = CstrPos + 4;

colStep = prmts.defaultBlockStepSize(2);
rowStep = prmts.defaultBlockStepSize(1);
zStep = prmts.defaultBlockStepSize(3); %this is for single paradigm in z

blockR = zeros(nCandidateFilesInFolder,1);
blockC = zeros(nCandidateFilesInFolder,1);
blockZ = zeros(nCandidateFilesInFolder,1);
%
% if strcmp(prmts.reverseXBlockNumbering,'yes'); colStep = -colStep;end
% if strcmp(prmts.reverseYBlockNumbering,'yes'); rowStep = -rowStep;end

stagePositionErrorYXZ = [];
mosaicAbsBlockPosFromStage = [];
mosaicAbsBlockPos = {};
imageBlockFullFileNames = {};
% %duplicate code for mpd or tiff files
switch prmts.fileTypeToUse
    case {'mpd','MPD'}
       
    case {'tif','tiff','TIF','TIFF'}
        if exist([path2dir prmts.baseName '-StagePositionError.mat'],'file') == 2
            load ([path2dir prmts.baseName '-StagePositionError.mat']);
        else
            disp('NO STAGE ERROR FILE!!!!!');
            disp('Will generate default');
            generateDummyError = 1;
            %set all to zero

        end % loading existing stage error file
        for ki = 1 : numel(dirContent)
            fname = dirContent(ki).name;
            zposStr = num2str(prmts.Zpos2use);
            if numel(zposStr)<2; zposStr = ['0' zposStr'];end
            %             if    ~isempty(regexp(fname,['\<' baseName
            %             '-Z[0-9]+-C[0-9]+-R[0-9]+-Ch' channel ],'ONCE'))
            if    ~isempty(regexp(fname,['\<' baseName '-Z' zposStr '+-C[0-9]+-R[0-9]+-Ch' channel ],'ONCE'))
                Z =  str2double(fname(ZstrPos + [1 2]));
                C =  str2double(fname(CstrPos + [1 2]));
                R =  str2double(fname(RstrPos + [1 2]));
                blockZ(ki) = Z;
                blockR(ki) = R;
                blockC(ki)= C;
                imageBlockFullFileNames{ki} = fullfile(prmts.path2dir,fname);
            end %dealing wiht valid files

        end %cycling directory content
    otherwise
        error(['File type ' prmts.fileTypeToUse ' not supported']);
end

%keep only valid
populatedBlocks = blockZ>0;
blockZ=blockZ(populatedBlocks);
blockR=blockR(populatedBlocks);
blockC=blockC(populatedBlocks);
numBlocks = sum(populatedBlocks);
imageBlockFullFileNames = imageBlockFullFileNames(populatedBlocks);
imageBlockFullFileNames = imageBlockFullFileNames';
%% create sparse layout representation
fprintf('\n%d\t%d\t%d',[blockZ blockC blockR]')

 if min(blockZ) ~= max(blockZ); warning('Multiple Z position detected, code is not tested for this case!!!!');end %#ok<WNTAG>
maxRCZ = max([blockR  blockC blockZ]);

%create col/row inversion as required

Ridx = 1 : maxRCZ(1); if strcmp(prmts.reverseYBlockNumbering,'yes'); Ridx = fliplr(Ridx);end
Cidx = 1 : maxRCZ(2); if strcmp(prmts.reverseXBlockNumbering,'yes'); Cidx = fliplr(Cidx);end
Zidx = 1 : maxRCZ(3); %reverse Z not supported yet
blockInLayoutRCZ = [reshape(Ridx(blockR),numel(blockR),1),reshape(Cidx(blockC),numel(blockC),1),reshape(Zidx(blockZ),numel(blockZ),1)];
blockInLayoutRCZ = blockInLayoutRCZ - repmat(min(blockInLayoutRCZ)-1,numBlocks,1);%offset to 1,1,1 for min layour rcz

mosaicLayout.numBlocks = numBlocks;
mosaicLayout.reverseYBlockNumbering = prmts.reverseYBlockNumbering;
mosaicLayout.reverseXBlockNumbering = prmts.reverseXBlockNumbering;
mosaicLayout.layoutSizeRCZ = maxRCZ;
mosaicLayout.blockInLayoutRCZ = blockInLayoutRCZ;
mosaicLayout.blockRCZ = [blockR blockC blockZ];
mosaicLayout.imageBlockFullFileNames = imageBlockFullFileNames;
mosaicLayout.layoutBlockCornerCoordsYXZ = (mosaicLayout.blockInLayoutRCZ - 1) .* repmat([rowStep colStep zStep],numBlocks,1) +1 ;
mosaicLayout.adjacentBlockPairList = MosaicTiling_buildBlockAdjacency(mosaicLayout);
mosaicLayout.adjacentBlockPairOffsetList= ...
mosaicLayout.layoutBlockCornerCoordsYXZ(mosaicLayout.adjacentBlockPairList(:,2),:) - mosaicLayout.layoutBlockCornerCoordsYXZ(mosaicLayout.adjacentBlockPairList(:,1),:);

%%

% clc
structfun(@display,mosaicLayout)
prmts.mosaicLayout = mosaicLayout;


fprintf('\nFinished %s in %6.2f sec',task,etime(clock,t0));
fprintf('\n%s',repmat('*',60,1));

% stgErr = zeros(numBlocks,3);
% for bi = 1 : numBlocks
%     stgErr(bi,:) = stagePositionErrorYXZ{blockR(bi),blockC(bi),blockZ(bi)};
% end

