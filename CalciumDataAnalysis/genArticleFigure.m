%% genArticleFigure.m - by Hagai Hargil, 17.7.26
% Take a stack and generate an article-worthy figure of it after the EP
% algorithm analyzed it.
% Currently works for a single file.

%% Parameters for user
scaleBarLength = 50;  % pixels
pixelPerUm = 1.15;  % enter a value if you wish to override the data taken from scanimage, or use '[]'

%% Internal parameters
addpath([prefix, '/data/MatlabCode/PBLabToolkit/External/altmany-export_fig-5be2ca4']);
startOfScaleBar = floor(size(Aout, 1) * 0.03);
heightOfScaleBar = floor(size(Aout, 2) * 0.09);
numOfCells = size(Fd_us{1, 1}, 1);
numOfTimepoints = size(Fd_us{1, 1}, 2);

%% Calculate pixel per micron if needed
if isempty(pixelPerUm)
    [header, data, imginfo] = scanimage.util.opentif([files(1).filename '.tif']); 
    pixelPerUm = header.SI.hRoiManager.linesPerFrame / ...
        (header.SI.hRoiManager.imagingFovUm(2, 1) - header.SI.hRoiManager.imagingFovUm(1, 1));
end

%% Display the basic image
fig = figure();
imagesc(mean(Aout, 3));
axis image; axis off;
colormap('gray');
hold on;

%% Add annotations    
lin = line([startOfScaleBar, startOfScaleBar + scaleBarLength], [heightOfScaleBar, heightOfScaleBar], 'Color', 'white', 'LineWidth', 3);
scaleBarText = sprintf('%d \\mum', floor(scaleBarLength * pixelPerUm));
text(startOfScaleBar / 2, heightOfScaleBar * 1.27, scaleBarText, 'Color', 'white'); 

%% Add contours
plot_contours_mod(A(:,keep),mean(Aout, 3),options,0,[],Coor,1,find(keep));
figure; hold on;
offsets = [1:numOfCells]';
offsets = repmat(offsets, 1, numOfTimepoints);  % adding offsets to all traces so that they won't overlap
maxVal = max(Fd_us{1, 1}, [], 2);
minVal = min(Fd_us{1, 1}, [], 2);
plot(header(1).frameTimestamps_sec(1, 1:numOfTimepoints), (Fd_us{1, 1} + minVal)./maxVal + offsets, ...
    'LineWidth', 1);
grid off; box off;
ylabel('Cell ID'); xlabel('Time [s]');
yticks(1:numOfCells);

%% Save
set(gcf, 'color', 'white');
export_fig(gca, [folder_name, filesep, 'traces.eps']);
set(fig, 'InvertHardCopy', 'off');
set(fig, 'color', 'white');
export_fig(fig, [folder_name, filesep, 'cells.eps']);