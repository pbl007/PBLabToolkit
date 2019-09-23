%This file is a template for populating variables that will be used to analyze a specific
%dataset. In the future, parameters should be obtained from database

%% File location
path_to_tif = '/Users/pb/Data/PBLab/David/WideField_GCamP6/CAMKII_vasc_occ_260319/CAMKII_vasc_occ_260319_MMStack_Pos0.ome.tif';

%% Acq parameters

%trial parameters - empty if no trial structure 
n_trials = 5; 
n_stim_frames = 80;
n_pre_frames = 40;
n_post_frames = 240;

%% Experiment parameters
%Experiments are hierarchically organized into conditions -> trials/continuous -> frames. 

experiment_type = 'trial_based'; %'trial_based' or 'continuous'

%conditions defined as structure with fields condition_name and condition_frame_range.
%Leave empty if no need to partition data into conditions
conditions = struct('condition_name',[],'condition_frame_range',[]); %populate or set conditions = [];
conditions(1).condition_name = 'occ_off';
conditions(1).condition_frame_range = [1 1800];
conditions(2).condition_name = 'occ_on';
conditions(2).condition_frame_range = [1801 3600];
conditions(3).condition_name = 'occ_on';
conditions(3).condition_frame_range = [3601 5400];


