clear
clc

%% pipeline for analyzing widefield data

% experiments are defined in .m file which populated a set of variables (see
% widefield_def_template.m). In the future this is to be populated from a datajoint.

job_def = struct('id',[],'status',[],'prmt_file',[],'notes',[]);
job_def(1).prmt_file = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/Parameter_files/dk2_vasc_occ_19042019_MMStack_Pos0_right_stim.m';


%define some global parameters and actions for all datasets
global_prmts.memory_safe = 0; % set to 1 to load data frame-by-frame and bin, slower.
global_prmts.binning_factor = 1;
global_prmts.save_binned_to_tif = 1;
global_prmts.override = 1; 
global_prmts.ref_allen = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions.mat';
global_prmts.ref_allen_rois = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions.mat';

%% Prepare job
job_i = 1;
run(job_def(job_i).prmt_file);
job_def(job_i).global_prmts = global_prmts;
job_def(job_i).exp_prmts = prmts;

%% Extract tif header - obtain frame timing and check that number of frames matches definitions

%get header info
fprintf('\nExtracting header details for job %d',job_i);
[~, t_msec, dt,ori_im_size,n_frames_in_parts] = widefield_toolkit__extract_tif_header(job_def(job_i));
job_def(job_i).exp_prmts.t_msec = t_msec;
job_def(job_i).exp_prmts.dt = dt;
job_def(job_i).exp_prmts.ori_im_size = ori_im_size;
job_def(job_i).exp_prmts.n_frames_in_parts = n_frames_in_parts;

fprintf('\tDone');

%validate - not implemented
% fprintf('\nValidating parameters for job %d',job_i);
% 
% fprintf('\tDone');

%% Extract tif data (concatenate, bin etc as needed)
fprintf('\nLoading data for job %d',job_i);
data_struct = widefield_toolkit__load_data(job_def(job_i));
fprintf('\tDone');

source_movie_avg = uint16(squeeze(mean(data_struct(1).data,3))); 

%% Parse data into conditions/trials - if needed
[data_struct] = widefield_toolkit__parse_trials(data_struct,job_def);

%% Alight to reference map
%define here reference image and map. The reference is  the allen 2d cortical regions, the
%sript will generate a resized and warpped new tif file.

load(job_def.global_prmts.ref_allen); %load allen_2d_cortex_map and allen_2d_cortex_rois

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
n_frames = size(data,3);
[nr, nc] = size(target_image_transformed);
data_transformed = zeros([nr nc n_frames],'uint16');
parfor frame_i = 1 : n_frames
    data_transformed(:,:,frame_i)= imwarp(data(:,:,frame_i),tform,'OutputView',imref2d(size(allen_2d_cortex_map)));
end



%% save transformed movie
source_movie_transformed_full_path = fullfile(path_source_movie,[source_movie_name '_transformed.tif']);
maketiff(data_transformed,source_movie_transformed_full_path);


%% save tranformed coordintes
source_movie_transform_data_full_path = fullfile(path_source_movie,[source_movie_name '_transfor.mat']);
save(source_movie_transform_data_full_path,'tform','movingPoints','fixedPoints');

%% compute df/f

%remove median
movie_median = median(data_transformed,3);
F = data_transformed-movie_median;
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