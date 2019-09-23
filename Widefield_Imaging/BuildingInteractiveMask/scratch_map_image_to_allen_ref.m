%scratch script to match Allen region to image, we keep image data fix and compute
%transform for the region map (will be applied to roi pixels)

clear
clc

%define here reference image and map
ref_image = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/test_crystal_skul.tif';
ref_allen = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions.mat';
[path_2_ref_image,ref_image_name]=fileparts(ref_image);
%% load reference image and map
ref = imread(ref_image);
load(ref_allen); %load allen_2d_cortex_map and allen_2d_cortex_rois

% here you need to manually choose -at least - 11 points of registration. 
% After choosing press file and then export to workspace
clear fixedPoints movingPoints cp
h = cpselect(uint16(allen_2d_cortex_map)*2^16,ref);%the first is modified to match the second

%% compute transform and display
tform = fitgeotrans(movingPoints,fixedPoints,'polynomial',3);
%tform = cp2tform(movingPoints(:,:),fixedPoints(:,:), 'nonreflective similarity');
allen_transformed = imwarp(allen_2d_cortex_map,tform,'OutputView',imref2d(size(ref))); %aligned map

figure; 
imshowpair(allen_transformed,ref);

%% transform each roi
% [x,y] = transformPointsForward(tform,u,v)%doesn't seem to work with polynomial fits
% (only affine transforms).
figure; hold on
[nr_a,nc_a] = size(allen_2d_cortex_map);
[nr_r,nc_r] = size(ref);

allen_2d_sampling_rois = allen_2d_cortex_rois;%create copy, then modify
roi_labels_transformed = zeros(nr_r,nc_r);%will hold labels of transformed rois

for i_roi = 1 : numel(allen_2d_cortex_rois)
    %create tmp image for each roi
    this_roi_img = zeros(nr_a,nc_a,'logical');
    this_roi_img(allen_2d_cortex_rois(i_roi).PixelIdxList) = 1;
    this_roi_img_transformed = imwarp(this_roi_img,tform,'OutputView',imref2d(size(ref))); %aligned map
   
    %obtain the transformed pixel ids to be used to extract data
    t = regionprops(this_roi_img_transformed,'PixelIdxList');
    allen_2d_sampling_rois(i_roi).PixelIdxList = t.PixelIdxList;
    roi_labels_transformed(t.PixelIdxList)=i_roi;
   
end
imshowpair(roi_labels_transformed,ref);

%% save tranformed coordintes
ptr_file = fullfile(path_2_ref_image,[ref_image_name '_allen_rois.mat']);
save(ptr_file,'allen_2d_sampling_rois','roi_labels_transformed','ref');

