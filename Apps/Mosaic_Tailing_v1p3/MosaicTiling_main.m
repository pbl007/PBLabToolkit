% Mosaic tiling set for uneven col/row data (eg. coronal sections)

clc
clear all
if isunix
    addpath('/media/sda1/MATLAB/work/MosaicTiling/v1.3');
    %     load prmts
    prmts.path2dir = '/home/pablo/Data/Testing_VIDA_API';%lapto linux
    prmts.path2RegistrationFunctionFolder = '/media/sda1/MATLAB/work/VidaSuite/RegistrationFunctionsFolder';
else
    %     cd('C:\MATLAB\work\2pToolkit_dev\MosaicTiling\v1.1');
    addpath('C:\MATLAB\R2007b\work\Pablo\MosaicTiling\v1.3');%Fornix
    %     load prmts
    %     prmts.path2dir = 'C:\MATLAB\work\2pToolkit_dev\MosaicTiling\testData\mpds\';%laptop
    %     prmts.path2dir = 'C:\MATLAB\R2007b\work\Pablo\MosaicTiling\v1.3';%fornix
    prmts.path2RegistrationFunctionFolder = 'C:\MATLAB\R2007b\work\vidasuite\registrationfunctionsfolder\';
    prmts.path2dir = 'D:\GFP-SMA_DAPI_TexasRed\CORONAL_20100118_pbDG\Testing_VIDA_API';
end



addpath(prmts.path2RegistrationFunctionFolder);


%% General behavior paramters
prmts.allowManualTileAdjustments = 1;


%% dataset parameters
%dataset location
% prmts.path2dir = 'C:\MATLAB\work\2pToolkit_dev\MosaicTiling\testData\mpds\';%laptop
% prmts.path2dir = '/media/sda1/MATLAB/work/2pToolkit_dev/MosaicTiling/testData/';%lapto linux
% 
% prmts.path2dir = 'c:\MATLAB\R2007b\work\Pablo\MosaicTiling\testData\';
% prmts.path2dir = 'H:\AOH\pbCA\tiffs\'; %data on KURU
baseName = 'pbDG-Z01-C10-R09-Ch1.tif';

% %kuru
%

%prmts.baseName = 'pbBU';
% prmts.fileTypeToUse = 'mpd'; %use either 'tif' or 'mpd' as possible files


% [baseName prmts.path2dir] = uigetfile({'*.mpd';'*.tif'});
prmts.baseName = baseName(1:strfind(baseName,'-')-1);
[null1,null2,prmts.ext]= fileparts(baseName);
prmts.fileTypeToUse = prmts.ext(2:end);
prmts.dirContent = dir(prmts.path2dir);

prmts.Zpos2use = [1];
prmts.Zpos2useList = [1];
prmts.xcorrCh = 3;%channel data to use for cross-correlations
prmts.channels2extract = [3];
prmts.channelStackedNames = {'NEUN';'HORD';'FITC'};
if numel(prmts.channels2extract)==1;prmts.xcorrCh = prmts.channels2extract;end

%dataset parameters
prmts.defaultBlockSize = [256 256 128];%default file size of each image stack
prmts.defaultBlockStepSize = [200 200 40]; %default displacement in Y,X,Z between image stack
prmts.altBlockStepSizeZ = [];

%algorithm behavior
prmts.reverseYBlockNumbering = 'yes'; %default is no (data taken top to bottom)
prmts.reverseXBlockNumbering = 'yes';%default is yes (data taken right to left)
prmts.computeMaxProjections = 1;
prmts.keepFiles = 0;
prmts.writeMosaicTofile = 0;

%block parameters
prmts.xstep = 200; %these parameters refer to the acquisition stepping
prmts.ystep = 200;
prmts.zstep = NaN;
if strcmp(prmts.ext,'.mpd')
    stk = mp2mat(fullfile(prmts.path2dir,baseName),'Header');
    prmts.stkWidth = stk.Header.Frame_Width;
    prmts.stkHeight = stk.Header.Frame_Height;
    prmts.stkDepth = stk.Header.Frame_Count;
else

    stkInfo = imfinfo(fullfile(prmts.path2dir,baseName));
    prmts.stkWidth = stkInfo(1).Width;
    prmts.stkHeight = stkInfo(1).Height;
    prmts.stkDepth = numel(stkInfo);
end %extracting block information


%compute overlap for later use (reconstruction stage)
prmts.overlap_X = prmts.stkWidth - prmts.xstep;
prmts.overlap_Y = prmts.stkHeight - prmts.ystep;
prmts.overlap_Z = prmts.stkDepth - prmts.zstep;

%nominal x,y and z offsets
prmts.maxStageErrRCZ = [20 20 Inf];%Max allowed stage offset, larger offsets are set to zero
prmts.nominalYXZ = [200 0 0]; %position of Z01-C01-R01. Adjust in case stage was not set to 0,0,0





%% get tile positions
prmts = getIrregularMosaicLayout(prmts);

%% extract data from files and generate mosaic max projection
prmts = MosaicTiling_extractData(prmts);
MosaicTiling_displayMosaicLayout(prmts,0);

%% Correlate vis Least Squares (API to VIDA)


registrationParameters = [];
registrationParameters.blockFileNameList = prmts.mosaicLayout.imageBlockFullFileNames;
registrationParameters.adjacentBlockPairList = prmts.mosaicLayout.adjacentBlockPairList;
registrationParameters.vidaProjectRootFolder = prmts.path2dir;
registrationParameters.nominalBlockStepSizeRC = [56 56];
registrationParameters.nominalBlockStepSizeZ = 50   ;
registrationParameters.variableZBlockStepSizeFlag = 0;
registrationParameters.emptyBlockCorrectionFlag = 0;
registrationParameters.emptyBlockThreshold = 0;
registrationParameters.adjacentBlockPairOffsetList = prmts.mosaicLayout.adjacentBlockPairOffsetList;
registrationParameters.corner_coords = prmts.mosaicLayout.layoutBlockCornerCoordsYXZ;


MaximizeProjectedBlockCorrelationSumIrregularLayout(registrationParameters)
