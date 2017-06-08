function varagout = MosaicTiling_displayMosaicLayout(prmts,ignoreMaxProj)
%
% 
varagout{1} = [];

h2fig = findobj('Tag',[prmts.baseName ' Mosaic Tiled']);
mode = 'display';
if ~isempty(h2fig);figure(h2fig);mode = 'update';end %only one copy per session


if strcmp(mode,'display');
    figure('Tag','MosaicDisplay','Name',[prmts.baseName ' Mosaic Tiled'],...
        'Tag',[prmts.baseName ' Mosaic Tiled']);hold on
end

%gather parameters
defaultBlockSize = prmts.defaultBlockSize;
mosaicAbsBlockPos = prmts.mosaicLayout.layoutBlockCornerCoordsYXZ;


blockR = prmts.mosaicLayout.blockInLayoutRCZ(:,1);
blockC = prmts.mosaicLayout.blockInLayoutRCZ(:,2);
blockZ = prmts.mosaicLayout.blockInLayoutRCZ(:,3);
numBlocks = prmts.mosaicLayout.numBlocks;


%%

if isfield(prmts,'mosaicBlockMaxXY') && ~ignoreMaxProj
    for bi = 1 : numBlocks
        blockPos = mosaicAbsBlockPos(bi,:);
        % rectangle('Position',[blockPos(2),blockPos(1) defaultBlockSize(2)...
        %                 defaultBlockSize(1)],'edgeColor','k',...
        %                 'lineWidth',2)
        if strcmp(mode,'display');
            h = imagesc(log(double(prmts.mosaicBlockMaxXY{blockR(bi),blockC(bi),blockZ(bi)})));
        else
            h = findobj(h2fig,'Tag',['BlockId_' num2str(bi)]);
        end
        set(h,'XData',[blockPos(2) blockPos(2)+defaultBlockSize(2)],...
            'YData',[blockPos(1) blockPos(1)+defaultBlockSize(1)],'Tag',['BlockId_' num2str(bi)],...
            'userdata',[prmts.mosaicLayout.blockRCZ(bi,:)],'AlphaData',0.5);
        if prmts.allowManualTileAdjustments; MosaicTiling_draggable(h);end
    end
    % axis image
    % spy(fliplr(prmts.mosaicLayout));axis square
else
    for bi = 1 : numBlocks
        blockPos = mosaicAbsBlockPos{blockR(bi),blockC(bi),blockZ(bi)} + ...
            stageError{blockR(bi),blockC(bi),blockZ(bi)};

        if strcmp(mode,'display');
            h = rectangle('Position',[blockPos(2),blockPos(1) defaultBlockSize(2)...
                defaultBlockSize(1)],'edgeColor','k',...
                'lineWidth',2);
            text(blockPos(2) + defaultBlockSize(2)/2,blockPos(1) + defaultBlockSize(1)/2,num2str(bi));
        else
            h = findobj(h2fig,'Tag',['BlockId_' num2str(bi)]);
        end
        set(h,'UserData',[blockPos(2) blockPos(2)+defaultBlockSize(2) ...
            blockPos(1) blockPos(1)+defaultBlockSize(1)],'Tag',['BlockId_' num2str(bi)],...
            'userdata',[blockR(bi),blockC(bi),blockZ(bi)]);
        if prmts.allowManualTileAdjustments; MosaicTiling_draggable(h);end
    end
end


axis image
set(gca,'ydir','reverse');
% colormap pink
