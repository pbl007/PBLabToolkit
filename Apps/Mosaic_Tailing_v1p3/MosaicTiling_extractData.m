function prmts = MosaicTiling_extractData(prmts)
% populate Mosoic structure with max projections (keep stack data in memory
% if required)

switch prmts.ext
    case{'.mpd','.MPD'}
        for k = 1 : numel(prmts.Zpos2useList)
            prmts.Zpos2use = prmts.Zpos2useList(k);
            %% get all max projections or just grab file content
            if prmts.computeMaxProjections
                prmts = MosaicTiling_getAllMaxProjections(prmts);
            else
                prmts = MosaicTiling_getBlocks(prmts);
                %% display layout
                MosaicTiling_displayMosaicLayout(prmts)
            end
            if prmts.writeMosaicTofile
                %% save large mosaic tiff for each zpos
                for chi = 1 : numel(prmts.channels2extract)
                    prmts.xcorrCh = prmts.channels2extract(chi);
                    MosaicTiling_writeMosaic2Tiff(prmts)
                end %cycling channels
            end
        end
    case {'.tif','.TIF','.tiff','.TIFF'} %load each channel separatedly
        prmts.channels2extractORI = prmts.channels2extract;
        for k = 1 : numel(prmts.Zpos2useList)
            prmts.Zpos2use = prmts.Zpos2useList(k);
            for chi = 1 : numel(prmts.channels2extractORI)

                prmts.channels2extract = prmts.channels2extractORI(chi);
                prmts.xcorrCh = prmts.channels2extract;

                %% get all max projections or just grab file content
                if prmts.computeMaxProjections
                    prmts = MosaicTiling_getAllMaxProjections(prmts);
                else
                    prmts = MosaicTiling_getBlocks(prmts);
                    %% display layout
                    %                     MosaicTiling_displayMosaicLayout(prmts)
                end
                if prmts.writeMosaicTofile
                    MosaicTiling_writeMosaic2Tiff(prmts);
                end
%                 MosaicTiling_writeTiledMaxProj2tiff(prmts)
            end %cycling channels
        end %cycling zpositions
end