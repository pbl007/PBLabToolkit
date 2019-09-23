%This file is a template for populating variables that will be used to analyze a specific
%dataset. In the future, parameters should be obtained from database

%% File location
% prmts.path_to_tif = '/Users/pb/Data/PBLab/David/WideField_GCamP6/CAMKII_vasc_occ_260319/CAMKII_vasc_occ_260319_MMStack_Pos0.ome.tif';
prmts.path_to_tif = [];
prmts.concatenate_files = 1; % 0 or 1. If set to 1, specify full path in cell array here belopw; path_to_tif can be empty in this case.
prmts.file_parts{1} = '/Users/pb/Data/PBLab/David/WideField_GCamP6/CAMKII_vasc_occ_260319/CAMKII_vasc_occ_260319_MMStack_Pos0.ome.tif';
prmts.file_parts{2} = '/Users/pb/Data/PBLab/David/WideField_GCamP6/CAMKII_vasc_occ_260319/CAMKII_vasc_occ_260319_MMStack_Pos0_1.ome.tif';


%% Acq parameters

%trial parameters - empty if no trial structure 
prmts.n_trials = 5; 
prmts.n_stim_frames = 80;
prmts.n_pre_frames = 40;
prmts.n_post_frames = 240;
prmts.channels = struct('channel_number',1,'channel_name','GCaMP'); %add more channels as needed

%% Experiment parameters
%Experiments are hierarchically organized into conditions -> trials/continuous -> frames. 

prmts.experiment_type = 'trial_based'; %'trial_based' or 'continuous'

%conditions defined as structure with fields condition_name and condition_frame_range.
%At leaset one condition must be defined
conditions = struct('condition_name',[],'condition_frame_range',[]); 
conditions(1).condition_name = 'occ_off';
conditions(1).condition_frame_range = [1 1800];
conditions(2).condition_name = 'occ_on';
conditions(2).condition_frame_range = [1801 3600];
conditions(3).condition_name = 'occ_off';
conditions(3).condition_frame_range = [3601 5400];



prmts.conditions = conditions;