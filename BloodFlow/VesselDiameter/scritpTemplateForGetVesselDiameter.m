%% script template for vessel diameter extraction
clearvars;

%% Addpaths
if startsWith(pwd, '/data')  % PBLab's server
    prefix = '';
else
    prefix = '/state/partition1/home/pblab';
end
addpath([prefix, '/data/MatlabCode/PBLabToolkit/ScanImageUtils']);
addpath([prefix, '/data/MatlabCode/ScanImage/SI2016bR0_2016-12-12_dd0af29383']);
addpath([prefix, '/data/MatlabCode/PBLabToolkit/External/efficient_subpixel_registration']);
addpath(genpath([prefix, '/data/MatlabCode/PBLabToolkit/External/chronux']));

%% Script parameters
fname = uipickfiles('Prompt', 'Please select one file for the vessel analysis',...
                    'FilterSpec', ['/export/home/pblab/data/David/THY_1_GCaMP_BEFOREAFTER_TAC_290517/', '*.tif'], 'Output', 'char');
% fname = '/export/home/pblab/data/David/THY_1_GCaMP_BEFOREAFTER_TAC_290517/747_HYPER_DAY_0__EXP_STIM/747_HYPER_DAY_0__EXP_STIM__FOV_1_00001.tif';
numOfChannels = 2;
channelOfVessels = 2;
expInfo.animal_ID='300';
expInfo.FOV_ID='1';
expInfo.nVessels = 2;

%% 
fprintf('Opening file...\n');
[header, data, imginfo] = opentif(fname); 
micPerPixelAt1x = header.SI.hRoiManager.scanZoomFactor * (header.SI.hRoiManager.imagingFovUm(2, 1) - header.SI.hRoiManager.imagingFovUm(1, 1)) / ...
    header.SI.hRoiManager.linesPerFrame;

%% Read the stack into memory and save it as a separate file
relData = data(:,:,channelOfVessels:numOfChannels:end);

%% Save also the other channel's mean image
otherChannel = 0;
if numOfChannels == 2
    if channelOfVessels == 2
        otherChannel = 1;
    else
        otherChannel = 2;
    end
    otherData = data(:, :, otherChannel:numOfChannels:end);
    otherDataMeanImage = mean(data, 3);
end
   
%%
% Convert to uint16
relDataUint = int32(relData) + abs(int32((min(min(min(relData))))));
relDataUint = uint16(relDataUint);
fname_after_split = [fname(1:end-4) '_vessels_only.tif'];

% fprintf('Writing new stack...\n');
% for idx = 1:size(relData, 3)
%     imwrite(relDataUint(:, :, idx), fname_after_split, 'WriteMode', 'append', ...
%             'Compression', 'none');
% end



%% Stack parameters
expInfo.Magnification = header.SI.hRoiManager.scanZoomFactor;
expInfo.Rotation = header.SI.hRoiManager.scanRotation;
expInfo.FrameRate = header.SI.hRoiManager.scanFrameRate;
expInfo.startToEndFrames = [1 imginfo.numFrames];
expInfo.micronsPerPixelAt1x=micPerPixelAt1x; 

mv_mpP = getVesselDiameter(fname, fname_after_split, relDataUint, expInfo);

%% Add the other channel's image to the struct
if otherChannel ~= 0
    mv_mpP(1).otherChannel = otherDataMeanImage;
end

%%
%the diameter data is stored in 
%       mv_mpP.Vessel.diameter
%       mv_mpP.Vessel.mean_diameter
%       mv_mpP.Vessel.std_diametery