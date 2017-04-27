
%% ATdataToTif - 
% Walks through an AT data directory, converts ets data to tif and generates a 'layout' file as required for the 
% stitching pipeline.
% we assume for the moment that each ribbon is acquired wiht EXACTLY the same number of overlapping tiles, in a
% snake-like fashion, starting from the top-left corner (which is by convention the 0,0 coordinate). Since the number of
% tiles (and the col/row pattern) do not change, we can "guess" the layer organization given nBlocksInCol x nBlocksInRow
% etc. 
% The final product after running this pipeline is as follows:
% T_ets - a table of block positions, pointing to original ets files location.
% T_tif - a larger table (wiht redundant information, based on t_ets) pointing to each tif file location for each channel.
% A directory (flat ) containing all tiles
% la

% Pablo - 20170414
clc
clear 
%% Setup dataset structure
expBaseName = 'Exp001';
path2exp = '';
path2TifFiles = '';


expStructure.expBaseName = 'Exp001';
expStructure.nCyc = 2;
expStructure.nRibbons = 2;
expStructure.nCols = 1;
expStructure.nRows = 2;
expStructure.nSlabsInRibbon  = [2 2];
expStructure.colOffset_pxl = 1490;
expStructure.rowOffset_pxl = 1580;
expStructure.nChannels = 4; %will attempt to load up to 4 channels, missing channel will generate warning
expStructure.alingement_ChNum = 1; %point to DAPI of other selected (synaptic) channel to be used for alingment, it is the only entry to the table.
expStructure.ribbonNumbers=[6 7];

%% NOTHING TO CHANGE BELOW THIS LINE!

%% generate table from experiment directory
T = generateATdataTable(path2exp,path2TifFiles,expStructure);
save(fullfile(path2TifFiles,[expBaseName '_layoutTable.mat']),'T');

%% convert to tif files

%prepare TIFF tree
if ~isdir(path2TifFiles);mkdir(path2TifFiles);end
for iCYC = 1 : expStructure.nCyc
    mkdir(fullfile(path2TifFiles,sprintf('Cyc%02d',iCYC)));
end
T=convertExpFromETStoTIF(T,expStructure);
% save(fullfile(path2TifFiles,[expBaseName '_layoutTable.mat']),'T');%enable once status is updated, see todo


%% generate trackEMlayout for each cycle (volume)
generateTrackEMlayoutFiles(T,expStructure,path2TifFiles);

%% generate aligner layout text file
generateAlignerLayoutFiles(T,expStructure,path2TifFiles)