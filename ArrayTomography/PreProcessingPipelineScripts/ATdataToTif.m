
%% ATdataToTif - 
% Walks through an AT data directory, converts ets data to tif and generates a 'layout' file as required for the 
% stitching pipeline.
% we assume for the moment that each ribbon is acquired wiht EXACTLY the same number of overlapping tiles, in a
% snake-like fashion, starting from the top-left corner (which is by convention the 0,0 coordinate). Since the number of
% tiles (and the col/row pattern) do not change, we can "guess" the layer organization given nBlocksInCol x nBlocksInRow
% etc. 

% Pablo - 20170414

%% Setup dataset structure
path2data = '/Volumes/AT/20170201_1p4_R16_Cyc2';
path2TifFiles = '/Volumes/AT/20170201_1p4_R16_Cyc2_tifs';

if ~isdir(path2tif);mkdir(path2tif);end


expStructure.nCyc = 2;
expStructure.nRibbons = 3;
expStructure.nCols = 2;
expStructure.nRows = 3;
expStructure.nSlabsInRibbon  = [3 2 3];
expStructure.colOffset_pxl = 1490;
expStructure.rowOffset_pxl = 1580;
