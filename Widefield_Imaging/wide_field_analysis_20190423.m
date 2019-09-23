clear
clc
%
addpath('/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging');
addpath('/Users/pb/Dropbox/__MATLAB/PBLabToolkit/External/crameri_v1.05/crameri');

%% pipeline for analyzing widefield data

% experiments are defined in .m file which populated a set of variables (see
% widefield_def_template.m). In the future this is to be populated from a datajoint.

job_def = struct('id',[],'status',[],'prmt_file',[],'notes',[]);
job_def(1).prmt_file = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/Parameter_files/dk2_vasc_occ_19042019_MMStack_Pos0_spont.m';
% job_def(1).prmt_file = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/Parameter_files/dk2_vasc_occ_19042019_MMStack_Pos0_right_stim.m';

%define some global parameters and actions for all datasets
global_prmts.memory_safe = 0; % set to 1 to load data frame-by-frame and bin, slower.
global_prmts.binning_factor = 1;
global_prmts.save_binned_to_tif = 1;
global_prmts.override = 1;
global_prmts.ref_allen_file_name = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions_crystal_skull.mat';
global_prmts.analyzed_data_dir = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/Analyzed_Data';

%analysis related
global_prmts.baseline_time_sec_cont = 20;
global_prmts.baseline_time_sec_trial = 0.5;
%% Prepare job
job_i = 1;
run(job_def(job_i).prmt_file);
job_def(job_i).global_prmts = global_prmts;
job_def(job_i).exp_prmts = prmts;

%prepare target dir and file name
if ~isfolder(global_prmts.analyzed_data_dir);mkdir(global_prmts.analyzed_data_dir);end
[~,base_file_name]=fileparts(job_def(1).exp_prmts.file_parts{1});
analyzed_data_file_name = fullfile(global_prmts.analyzed_data_dir,[base_file_name '.mat']);

%% Extract tif header - obtain frame timing and check that number of frames matches definitions

%get header info
fprintf('\nExtracting header details for job %d',job_i);
[~, t_msec, dt,ori_im_size,n_frames_in_parts] = widefield_toolkit__extract_tif_header(job_def(job_i));
job_def(job_i).exp_prmts.t_msec = t_msec;
job_def(job_i).exp_prmts.dt = dt;
job_def(job_i).exp_prmts.ori_im_size = ori_im_size;
job_def(job_i).exp_prmts.n_frames_in_parts = n_frames_in_parts;

fprintf('\tDone');


%% Extract tif data (concatenate, bin etc as needed)
fprintf('\nLoading data for job %d',job_i);
data_struct = widefield_toolkit__load_data(job_def(job_i));
fprintf('\tDone');

%% register to Allen cortical atlas (modified for crystal skull)
fprintf('\nRegistering to ref atlas for job %d',job_i);
[data_struct,reg_prmts] = widefield_toolkit__align_to_atlas(data_struct,job_def(job_i));
job_def(1).reg_prmts = reg_prmts;
fprintf('\tDone');

%% Parse data into conditions/trials - if needed
if strcmp(job_def(job_i).exp_prmts.experiment_type,'trial_based')
    fprintf('\nParsing trials for job %d',job_i);
    [data_struct] = widefield_toolkit__parse_trials(data_struct,job_def(job_i));
    fprintf('\tDone');
    
    fprintf('\nGenerating trial averaged movies for job %d',job_i);
    widefield_toolkit__movie_trials(data_struct,job_def(job_i));
    fprintf('\tDone');
else
    %continuous data - not implemented yet
    fprintf('\nGenerating trial averaged movies for job %d',job_i);
    widefield_toolkit__movie_continuous(data_struct,job_def(job_i));
    fprintf('\tDone');
end

%% save
fprintf('\nSaving data for job %d',job_i);
this_job_def = job_def(job_i);
save(analyzed_data_file_name,'this_job_def','data_struct','-V7.3')
fprintf('\tDone');

% %% extract ROI data
% load (global_prmts.ref_allen_file_name)% ref_allen_rois
% 
% 
% %extrad dF for each roi (average over roi pixels)
% roi_struct = widefield_toolkit__extract_roi_data(dF,allen_2d_cortex_rois);
% all_roi_dF=[roi_struct.mean_frame_data];
% 
% %compute cross correlation coefficient
% R = corrcoef(all_roi_dF);
% 
% imagesc(R)
% crameri('berlin');
% 
% 
% %% cluster matrix
% len = size(R,1);
% y=pdist(R); %use corrcoeff distances
% Z=linkage(y);
% [h,T,v] = dendrogram(Z,len);
% %reorder matrix
% Rclust = R(v,v);
% imagesc(real(log(Rclust)));
% axis square
% axis off
% xlim([1 64])
% ylim([1 64])
% crameri('berlin');

