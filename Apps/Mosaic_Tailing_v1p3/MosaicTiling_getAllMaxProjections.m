function prmts = MosaicTiling_getAllMaxProjections(prmts)


task = 'Generating max porjections';
fprintf('\n%s',repmat('*',60,1));
fprintf('\n%s\n',task);
t0 = clock;

path2dir = prmts.path2dir;
baseName = prmts.baseName;
channel = num2str(prmts.xcorrCh);
numBlocks = prmts.mosaicLayout.numBlocks;
blockR = prmts.mosaicLayout.blockInLayoutRCZ(:,1);
blockC = prmts.mosaicLayout.blockInLayoutRCZ(:,2);

% blockZ = prmts.blockZ;
Zpos2use = prmts.Zpos2use;
mosaicBlockMaxXY = cell(prmts.mosaicLayout.layoutSizeRCZ);
mosaicBlockMaxXZ = cell(prmts.mosaicLayout.layoutSizeRCZ);
mosaicBlockMaxYZ = cell(prmts.mosaicLayout.layoutSizeRCZ);


%%
%duplicate for supporting mpd and tiff
bIdx = 1 : numBlocks;
% blocks2use = blockZ == Zpos2use;
% numBlocks = sum(blocks2use);
blockZ = zeros(1,numBlocks)+prmts.Zpos2use;

switch prmts.fileTypeToUse
    case {'mpd','MPD'}

        for iBLK = 1 : numBlocks           
            [null,fname,ext] = fileparts(prmts.mosaicLayout.imageBlockFullFileNames{iBLK,:});
            %make sure to load desired channel
            chPos = regexp(fname,'-Ch[0-9]');
            fname =fullfile(path2dir, [fname(1:chPos+2)  channel ext]);
            fprintf('Computing max projections for %s\t%d / %d\n',fname,iBLK,numBlocks);
            stk = MosaicTiling_mp2mat(fname,prmts.channels2extract);
            mosaicBlockMaxXY{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))}  =...
                squeeze(max(stk.(['Ch' channel]),[],3));
            mosaicBlockMaxXZ{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))}  =...
                squeeze(max(stk.(['Ch' channel]),[],1))';
            mosaicBlockMaxYZ{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))}  =...
                squeeze(max(stk.(['Ch' channel]),[],2))';
            
%             blockPos = prmts.mosaicAbsBlockPos{blockR(iBLK),blockC(iBLK),blockZ(iBLK)};
%             h = imagesc(log(double(mosaicBlockMaxXY{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))})));
%             set(h,'XData',[blockPos(2) blockPos(2)+defaultBlockSize(2)],...
%                 'YData',[blockPos(1) blockPos(1)+defaultBlockSize(1)]);
%             MosaicTiling_draggable(h)
%             drawnow;

            if prmts.keepFiles
                mosaicBlock{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))} = stk;
            end
            prmts.defaultBlockSize = size(stk.(['Ch' channel]));
        end
    case {'tif','tiff','TIF','TIFF'}
        for iBLK = 1 : numBlocks
            [null,fname,ext] = fileparts(prmts.mosaicLayout.imageBlockFullFileNames{iBLK,:});
            %make sure to load desired channel
            chPos = regexp(fname,'-Ch[0-9]');
            fname =fullfile(path2dir, [fname(1:chPos+2)  channel ext]);
            fprintf('Computing max projections for %s\t%d / %d\n',fname,iBLK,numBlocks);
            stk = readtiff(fname);
%             mosaicBlockMaxXY{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))}  = squeeze(max(stk,[],3));
%             mosaicBlockMaxXZ{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))}  =...
%                 squeeze(max(stk,[],1))';
%             mosaicBlockMaxYZ{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))}  =...
%                 squeeze(max(stk,[],2))';

            mosaicBlockMaxXY{blockR(iBLK),blockC(iBLK),blockZ(iBLK)}  = squeeze(max(stk,[],3));
            mosaicBlockMaxXZ{blockR(iBLK),blockC(iBLK),blockZ(iBLK)}  =...
                squeeze(max(stk,[],1))';
            mosaicBlockMaxYZ{blockR(iBLK),blockC(iBLK),blockZ(iBLK)}  =...
                squeeze(max(stk,[],2))';
            
%             blockPos = prmts.mosaicAbsBlockPos{blockR(iBLK),blockC(iBLK),blockZ(iBLK)};
%             h = imagesc(log(double(mosaicBlockMaxXY{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))})));
%             set(h,'XData',[blockPos(2) blockPos(2)+defaultBlockSize(2)],...
%                 'YData',[blockPos(1) blockPos(1)+defaultBlockSize(1)]);
%             MosaicTiling_draggable(h)
%             drawnow;
            if prmts.keepFiles
                mosaicBlock{blockR(bIdx(iBLK)),blockC(bIdx(iBLK)),blockZ(bIdx(iBLK))} = stk;
            end
        end
        prmts.defaultBlockSize = size(stk);
    otherwise
        error(['File type ' prmts.fileTypeToUse ' not supported']);
end

prmts.mosaicBlockMaxXY = mosaicBlockMaxXY;
prmts.mosaicBlockMaxXZ = mosaicBlockMaxXZ;
prmts.mosaicBlockMaxYZ = mosaicBlockMaxYZ;
if prmts.keepFiles
    prmts.mosaicBlock = mosaicBlock;
end



fprintf('\nFinished %s in %6.2f sec',task,etime(clock,t0));
fprintf('\n%s\n',repmat('*',60,1));
