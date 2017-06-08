
% %% Outlier removal
% 
% %%%%%%%%%%%%%%%%%%% CHANGE THIS WITH TAG RESONANCE FREQUENCY %%%%%%%%%%%%%%%%%%%%%%%%
% %                                                                                   %            
% %     UltraFastLensFrequency = 188000; % [Hz] - CHANGE IF NECESSARY                   %
% UltraFastLensFrequency = 0.2; % [Hz] - WORKAROUND!!!                   %
%         
% %     GalvoFrequency = 400 ; % [Hz] - Minimal galvo frequency, change if necessary    %
% GalvoFrequency = 0.2; % [Hz] - WORKAROUND!!!                   %
% 
%     %                                                                                   %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% ExpectedLensPeriodicityInBins = 1 ./ (0.8e-9 .* UltraFastLensFrequency); % The expected number of 800 ps time bins within a single TAG lens oscillation
% WrongLensPeriodicityReadings = ExpectedLensPeriodicityInBins .* 1.0001; % Periodicities higher by 0.01% of expected value are presumably outright wrong 
% 
% ExpectedGalvoPeriodicityInBins = 1 ./ (0.8e-9 .* GalvoFrequency); % The expected number of 800 ps time bins within a single TAG lens oscillation
% WrongGalvoPeriodicityReadings = ExpectedGalvoPeriodicityInBins .* 1.2; % Periodicities higher by 20% of expected value are presumably outright wrong 

% 
% LegalHitsZ = cellfun(@(x) x(x<WrongLensPeriodicityReadings ), TotalHitsZ, 'UniformOutput',false);
% LegalHitsX = cellfun(@(x) x(x<WrongGalvoPeriodicityReadings), TotalHitsX, 'UniformOutput',false);

% TotalHitsZ(TotalHitsZ>WrongLensPeriodicityReadings) = WrongLensPeriodicityReadings; % Dumping incorrect axial coordinates
% TotalHitsX(TotalHitsX>WrongGalvoPeriodicityReadings) = WrongGalvoPeriodicityReadings; % Dumping incorrect lateral coordinates


%% Raw image size

% ShrinkFactorX = max(LegalHitsX{1}) ./ 1000;
% ShrinkFactorZ = max(LegalHitsZ{1}) ./ 1000;

% ShrinkFactorX = max(TotalHitsX{1}) ./ 1000;
% ShrinkFactorZ =  max(TotalHitsZ{1}) ./ 1000;

% 
% MaxX = round( max(LegalHitsX{1}) ./ ShrinkFactorX);
% MaxZ = round( max(LegalHitsZ{1}) ./ ShrinkFactorZ);


% MaxX = round( max(TotalHitsX{1}) ./ ShrinkFactorX);
% MaxZ = round( max(TotalHitsZ{1}) ./ ShrinkFactorZ);

% RawImage = single(zeros(MaxX+1,MaxZ+1,max(NumFrames,1)));

% RescaledZ = cellfun(@(x) floor(x ./ ShrinkFactorZ ) + 1, TotalHitsZ, 'UniformOutput',false);
% RescaledX = cellfun(@(x) floor(x ./ ShrinkFactorX ) + 1, TotalHitsX, 'UniformOutput',false);

%% Populating the raw image

SizeX = 1500;
SizeY = 150;
RawImage = single(zeros(SizeX,SizeY,max(NumFrames,1)));
C = cell(NumFrames);
% Building a histogram of photon locations

for m = 1:NumFrames
    if numel(TotalHitsX{m})
        Minumel = min(numel(TotalHitsX{m}), numel(TotalHitsZ{m}));
        [ RawImage(:,:,m), C{m} ] = hist3([TotalHitsX{m}(1:Minumel)  TotalHitsZ{m}(1:Minumel)],'Nbins',[SizeX SizeY]);
%         for n = 1:numel(TotalHitsX{m})
% %             RawImage(round(LegalHitsX{m}(n)./ShrinkFactorX) +1 ,   round(LegalHitsZ{m}(n)./ShrinkFactorZ)+1, m) = 1 + RawImage(round(LegalHitsX{m}(n)./ShrinkFactorX) +1 ,   round(LegalHitsZ{m}(n)./ShrinkFactorZ)+1, m);
%             RawImage(RescaledX{m}(n), RescaledZ{m}(n), m) = 1 + RawImage(RescaledX{m}(n), RescaledZ{m}(n), m);
 
%         end
    end
end
