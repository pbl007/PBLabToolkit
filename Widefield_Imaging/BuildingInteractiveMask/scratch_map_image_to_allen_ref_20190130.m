%scratch script to match Allen region to image, we keep image data fix and compute
%transform for the region map (will be applied to roi pixels)

clear
clc

%define here reference image and map. The reference is  the allen 2d cortical regions, the
%sript will generate a resized and warpped new tif file.
% target_image = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/test_crystal_skul.tif';
source_movie_filename = '/Users/pb/Dropbox/__DATA2/Multimodal_imaging/M02/widefield/spont_MMStack_Pos0.ome.tif';
ref_allen = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions.mat';
ref_allen_rois = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions.mat';

[path_source_movie,source_movie_name]=fileparts(source_movie_filename);

%%sanitize name and keep everything before fist '.'
source_movie_name = source_movie_name(1:strfind(source_movie_name,'.')-1);
%% load reference image and map
source_movie = loadmovie(source_movie_filename);
source_movie_avg = uint16(squeeze(mean(source_movie,3)));
load(ref_allen); %load allen_2d_cortex_map and allen_2d_cortex_rois

% here you need to manually choose -at least - 11 points of registration.
% After choosing press file and then export to workspace
clear fixedPoints movingPoints cp
h = cpselect(imadjust(source_movie_avg),uint16(allen_2d_cortex_map)*2^16);%the first is modified to match the second

%% compute transform and display
tform = fitgeotrans(movingPoints,fixedPoints,'polynomial',3);
%tform = cp2tform(movingPoints(:,:),fixedPoints(:,:), 'nonreflective similarity');
target_image_transformed = imwarp(source_movie_avg,tform,'OutputView',imref2d(size(allen_2d_cortex_map))); %aligned map

figure;
imshowpair(~allen_2d_cortex_map,target_image_transformed);

%% transform eahc frame, save as new tif
n_frames = size(source_movie,3);
[nr, nc] = size(target_image_transformed);
movie_transformed = zeros([nr nc n_frames],'uint16');
parfor frame_i = 1 : n_frames
    movie_transformed(:,:,frame_i)= imwarp(source_movie(:,:,frame_i),tform,'OutputView',imref2d(size(allen_2d_cortex_map)));
end

%% save transformed movie
source_movie_transformed_full_path = fullfile(path_source_movie,[source_movie_name '_transformed.tif']);
maketiff(movie_transformed,source_movie_transformed_full_path);


%% save tranformed coordintes
source_movie_transform_data_full_path = fullfile(path_source_movie,[source_movie_name '_transfor.mat']);
save(source_movie_transform_data_full_path,'tform','movingPoints','fixedPoints');

%% compute df/f

%remove median
movie_median = median(movie_transformed,3);
F = movie_transformed-movie_median;
dF = diff(F,1,3);

%% extract ROI data
load (ref_allen_rois)% ref_allen_rois

%extrad dF for each roi (average over roi pixels)
roi_struct = widefield_toolkit__extract_roi_data(dF,allen_2d_cortex_rois);
all_roi_dF=[roi_struct.mean_frame_data];

%compute cross correlation coefficient
R = corrcoef(all_roi_dF);

imagesc(R)

%% cluster matrix
len = size(R,1);
y=pdist(R); %use corrcoeff distances 
Z=linkage(y);
[h,T,v] = dendrogram(Z,len);
%reorder matrix
Rclust = R(v,v);
imagesc(real(log(Rclust)));
axis square
axis off
xlim([1 64])
ylim([1 64])

%% display transformed movie

for frame_i = 1 : n_frames
    imagesc(squeeze(F(:,:,frame_i)))
    title(num2str(frame_i))
    drawnow
    
end