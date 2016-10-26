function [res] = LSPIV(fileNameArbData,prmts)
% LSPIV with parallel processing enabled - implementation for
% pathAnalyzeHelper analysis pipeline
%
% For information on original code, please see corresponding manuscript:
%
% 'Line-Scanning Particle Image Velocimetry: an Optical Approach for
% Quantifying a Wide Range of Blood Flow Speeds in Live Animals'
% by Tyson N. Kim, Patrick W. Goodwill, Yeni Chen, Steven M. Conolly, Chris
% B. Schaffer, Dorian Liepmann, Rong A. Wang
%
% PWG 3/28/2012
%
% Modified by Pablo  05/Sept/2016



% Parameters to improve fits
maxGaussWidth = prmts.maxGaussWidth;  % maximum width of peak during peak fitting

% Judge correctness of fit
numstd = prmts.numstd; %num of stdard deviation from the mean before flagging
windowsize = prmts.windowsize; %in # scans, this will be converted to velocity points
%if one scan is 1/2600 s, then windowsize=2600 means
%a 1 second moving window.  Choose the window size
%according to experiment.

%settings for artery/capillaries/custom
numavgs = prmts.numavgs;  %up to 100 (or more) for noisy or slow data
skipamt = prmts.skipamt;   %if it is 2, it skips every other point.  3 = skips 2/3rds of points, etc.
shiftamt = prmts.shiftamt;

startColumn   = prmts.startColumn;      % Defines what part of the image we perform LSPIV on.
endColumn     = prmts.endColumn;

%% Import the data from a multi-frame tif and make into a single array
%  The goal is a file format that is one single array,
%  so modify this section to accomodate your raw data format.
%
%  This particular file format assumes
disp('LSPIV - import raw data');

%
imageLines = flextiffread(fileNameArbData);
imageLines = imageLines(:,:,1:3);

% reshape  crate single time (rows) x space (cols) matrix
%matrix

[nRows,nCols,nFrames]=size(imageLines);
imageLines=reshape(permute(imageLines,[1 3 2]),nRows * nFrames,nCols);


tic

%% minus out background signal (PWG 6/4/2009)
disp('DC correction')
DCoffset = sum(imageLines,1) / size(imageLines,1);
imageLinesDC = imageLines - uint16(repmat(DCoffset,size(imageLines,1),1));

%% do LSPIV correlation
disp('LSPIV begin');

scene_fft  = fft(imageLinesDC(1:end-shiftamt,:),[],2);
test_img   = zeros(size(scene_fft));
test_img(:,startColumn:endColumn)   = imageLinesDC(shiftamt+1:end, startColumn:endColumn);
test_fft   = fft(test_img,[],2);
W      = 1./sqrt(abs(scene_fft)) ./ sqrt(abs(test_fft)); % phase only

LSPIVresultFFT      = scene_fft .* conj(test_fft) .* W;
LSPIVresult         = ifft(LSPIVresultFFT,[],2);
disp('LSPIV complete');

toc

%% find shift amounts
disp('Find the peaks');
velocity = [];
maxpxlshift = round(size(imageLines,2)/2)-1;


index_vals = skipamt:skipamt:(size(LSPIVresult,1) - numavgs);
numpixels = size(LSPIVresult,2);
velocity  = nan(size(index_vals));
amps      = nan(size(index_vals));
sigmas    = nan(size(index_vals));
goodness  = nan(size(index_vals));

%% iterate through
parfor index = 1:length(index_vals)
    
    if mod(index_vals(index),100) == 0
        fprintf('line: %d\n',index_vals(index))
    end
    
    LSPIVresult_AVG   = fftshift(sum(LSPIVresult(index_vals(index):index_vals(index)+numavgs,:),1)) ...
        / max(sum(LSPIVresult(index_vals(index):index_vals(index)+numavgs,:),1));
    
    % find a good guess for the center
    c = zeros(1, numpixels);
    c(numpixels/2-maxpxlshift:numpixels/2+maxpxlshift) = ...
        LSPIVresult_AVG(numpixels/2-maxpxlshift:numpixels/2+maxpxlshift);
    [maxval, maxindex] = max(c);
    
    % fit a guassian to the xcorrelation to get a subpixel shift
    options = fitoptions('gauss1');
    options.Lower      = [0    numpixels/2-maxpxlshift   0            0];
    options.Upper      = [1e9  numpixels/2+maxpxlshift  maxGaussWidth 1];
    options.StartPoint = [1 maxindex 10 .1];
    [q,good] = fit((1:length(LSPIVresult_AVG))',LSPIVresult_AVG','a1*exp(-((x-b1)/c1)^2) + d1',options);
    
    %save the data
    velocity(index)  = (q.b1 - size(LSPIVresult,2)/2 - 1)/shiftamt;
    amps(index)      = q.a1;
    sigmas(index)    = q.c1;
    goodness(index)  = good.rsquare;
end
%% find possible bad fits
toc

% Find bad velocity points using a moving window
pixel_windowsize = round(windowsize / skipamt);

badpixels = zeros(size(velocity));
for index = 1:1:length(velocity)-pixel_windowsize
    pmean = mean(velocity(index:index+pixel_windowsize-1)); %partial window mean
    pstd  = std(velocity(index:index+pixel_windowsize-1));  %partial std
    
    pbadpts = find((velocity(index:index+pixel_windowsize-1) > pmean + pstd*numstd) | ...
        (velocity(index:index+pixel_windowsize-1) < pmean - pstd*numstd));
    
    badpixels(index+pbadpts-1) = badpixels(index+pbadpts-1) + 1; %running sum of bad pts
end
badvals  = find(badpixels > 0); % turn pixels into indicies
goodvals = find(badpixels == 0);

meanvel  = mean(velocity(goodvals)); %overall mean
stdvel   = std(velocity(goodvals));  %overall std

res.meanvel = meanvel;
res.stdvel = stdvel;
res.badvals = badvals;
res.goodvals = goodvals;
res.index_vals = index_vals;
res.velocity_pixels_per_scan = velocity;

if prmts.doPlot
    % show results
    figure
    subplot(3,1,1)
    imgtmp = zeros([size(imageLines(:,startColumn:endColumn),2) size(imageLines(:,startColumn:endColumn),1) 3]); % to enable BW and color simultaneously
    imgtmp(:,:,1) = imageLines(:,startColumn:endColumn)'; imgtmp(:,:,2) = imageLines(:,startColumn:endColumn)'; imgtmp(:,:,3) = imageLines(:,startColumn:endColumn)';
    imagesc(imgtmp/max(max(max(imgtmp))))
    title('Raw Data');
    ylabel('[pixels]');
    %colormap('gray');
    
    subplot(3,1,2)
    imagesc(index_vals,-numpixels/2:numpixels/2,fftshift(LSPIVresult(:,:),2)');
    title('LSPIV xcorr');
    ylabel({'displacement'; '[pixels/scan]'});
    
    
    subplot(3,1,3)
    plot(index_vals, velocity,'r-.');
    hold all
    plot(index_vals(badvals), velocity(badvals), 'ro');
    hold off
    xlim([index_vals(1) index_vals(end)]);
    ylim([meanvel-stdvel*4 meanvel+stdvel*4]);
    title('Fitted Pixel Displacement');
    ylabel({'displacement'; '[pixels/scan]'});
    xlabel('index [pixel]');
    
    h = line([index_vals(1) index_vals(end)], [meanvel meanvel]);
    set(h, 'LineStyle','--','Color','k');
    h = line([index_vals(1) index_vals(end)], [meanvel+stdvel meanvel+stdvel]);
    set(h, 'LineStyle','--','Color',[.5 .5 .5]);
    h = line([index_vals(1) index_vals(end)], [meanvel-stdvel meanvel-stdvel]);
    set(h, 'LineStyle','--','Color',[.5 .5 .5]);
    fprintf('\nMean  Velocity %0.2f [pixels/scan]\n', meanvel);
    fprintf('Stdev Velocity %0.2f [pixels/scan]\n', stdvel);
    
end


