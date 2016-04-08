
%% Outlier removal

%%%%%%%%%%%%%%%%%%% CHANGE THIS WITH TAG RESONANCE FREQUENCY %%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                   %            
    UltraFastLensFrequency = 188000; % [Hz] - CHANGE IF NECESSARY                   %
    GalvoFrequency = 400 ; % [Hz] - Minimal galvo frequency, change if necessary    %
%                                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExpectedLensPeriodicityInBins = 1 ./ (0.8e-9 .* UltraFastLensFrequency); % The expected number of 800 ps time bins within a single TAG lens oscillation
WrongLensPeriodicityReadings = ExpectedLensPeriodicityInBins .* 1.0001; % Periodicities higher by 0.01% of expected value are presumably outright wrong 

ExpectedGalvoPeriodicityInBins = 1 ./ (0.8e-9 .* GalvoFrequency); % The expected number of 800 ps time bins within a single TAG lens oscillation
WrongGalvoPeriodicityReadings = ExpectedGalvoPeriodicityInBins .* 1.2; % Periodicities higher by 20% of expected value are presumably outright wrong 


TotalHitsZ(TotalHitsZ>WrongLensPeriodicityReadings) = WrongLensPeriodicityReadings; % Dumping incorrect axial coordinates
TotalHitsX(TotalHitsX>WrongGalvoPeriodicityReadings) = WrongGalvoPeriodicityReadings; % Dumping incorrect lateral coordinates


%% Raw image size

ShrinkFactorX = max(TotalHitsX(:)) ./ 1000;
ShrinkFactorZ = max(TotalHitsZ(:)) ./ 1000;

MaxX = round( max(TotalHitsX(:)) ./ ShrinkFactorX);
MaxZ = round( max(TotalHitsZ(:)) ./ ShrinkFactorZ);

RawImage = (zeros(MaxX+3,MaxZ+3));



%% Populating the raw image

% Adding photons one at a time to the relevant voxel

for m = 1:numel(TotalHitsX)
    RawImage(round(TotalHitsX(m)./ShrinkFactorX) +1 ,   round(TotalHitsZ(m)./ShrinkFactorZ)+1) = 1 + RawImage(round(TotalHitsX(m)./ShrinkFactorX) +1 ,   round(TotalHitsZ(m)./ShrinkFactorZ)+1);
end