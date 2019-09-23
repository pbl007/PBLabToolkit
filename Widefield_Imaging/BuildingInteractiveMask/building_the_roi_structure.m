%just to keep track of steps to build roi structure from Allen 2D contour
%(one hemisphere) provided by Ariel Gilad

%load the original contour and create mirrored image (i.e. left/right hemispheres)
clear 
clc
load /Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/FromAriel/'wf areas_scaled.mat';
A_mask= A_scaled>0;
A_mask=A_mask';%flip so rostral is up as in our imaging setup
tmp = A_mask(:,55:205);%trim
tmp = ~tmp;%invert vals
%mirror and concatenate to obtain two hemispheres
allen_2d_cortex_map = [fliplr(tmp) tmp];

%% label and extract rois - there 34 roi/hemisphere
L = bwlabel(allen_2d_cortex_map,4);%we use 4-adjacency as some of the contour lines are 1-pixel width only
allen_2d_cortex_rois = regionprops(L,'Area','Centroid','PixelIdxList');
allen_2d_cortex_rois = allen_2d_cortex_rois(2:end);%first roi is background and we do not need it.
allen_2d_cortex_rois(1).Name = '';

%% display
imagesc(L);
map = hot(68);
map(1,:) = [0 0.75 0.75].*0.5;
colormap(map)
axis off
%% save
save allen_2d_cortex_regions.mat allen_2d_cortex_map allen_2d_cortex_rois
