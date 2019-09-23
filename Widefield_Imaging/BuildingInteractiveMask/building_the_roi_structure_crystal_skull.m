%just to keep track of steps to build roi structure from Allen 2D contour
%(one hemisphere) provided by Ariel Gilad

%load the original contour and create mirrored image (i.e. left/right hemispheres)
% clear 
% clc
allen_2d_cortex_map = imread('/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions_crystal_skull-01.tif');
allen_2d_cortex_map = mean(allen_2d_cortex_map,3)>0;
allen_2d_cortex_map = imresize(allen_2d_cortex_map,0.3);
imagesc(allen_2d_cortex_map)
%% label and extract rois - there 34 roi/hemisphere
L = bwlabel(~allen_2d_cortex_map,4);%we use 4-adjacency as some of the contour lines are 1-pixel width only
allen_2d_cortex_rois = regionprops(L,'Area','Centroid','PixelIdxList');
allen_2d_cortex_rois = allen_2d_cortex_rois(2:end);%first roi is background and we do not need it.
allen_2d_cortex_rois(1).Name = '';

%roi 1 is background so remove
allen_2d_cortex_rois = allen_2d_cortex_rois(1:end);
n_rois = numel(allen_2d_cortex_rois);
%% display
L(L==1)=0;
imagesc(L);
map = hot(n_rois+1);
map(1,:) = [0 0.75 0.75].*0.5;
colormap(map)
axis off

for roi_i = 1 : n_rois
   ctr = deal(allen_2d_cortex_rois(roi_i).Centroid);
   text(ctr(1),ctr(2),sprintf('%d',roi_i),'Color','c','FontWeight','bold','FontSize',16) 
end
axis image
%% build mask
pixel_list = allen_2d_cortex_rois.PixelIdxList;
A = L;
A(A==1)=0;
A(A>0)=1;
A=imdilate(A,strel('disk',2));
A=imerode(A,strel('disk',2));
A=imclose(A,strel('disk',4));
crystal_skull_mask = uint16(A);
imagesc(crystal_skull_mask)

%% build hemisphere mask and rois
H = bwlabel(crystal_skull_mask);
imagesc(H)
allen_2d_cortex_hemisphere_rois = regionprops(H,'ConvexHull');
left_hemisphere_coor = allen_2d_cortex_hemisphere_rois(1).ConvexHull;
right_hemisphere_coor = allen_2d_cortex_hemisphere_rois(2).ConvexHull;

%% save
save /Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions_crystal_skull.mat allen_2d_cortex_map allen_2d_cortex_rois crystal_skull_mask allen_2d_cortex_hemisphere_rois left_hemisphere_coor right_hemisphere_coor