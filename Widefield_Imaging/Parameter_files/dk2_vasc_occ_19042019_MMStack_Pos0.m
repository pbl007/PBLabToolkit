%This file is a template for populating variables that will be used to analyze a specific
%dataset. In the future, parameters should be obtained from database

%% File location
% prmts.path_to_tif = '/Users/pb/Data/PBLab/David/WideField_GCamP6/CAMKII_vasc_occ_260319/CAMKII_vasc_occ_260319_MMStack_Pos0.ome.tif';
% prmts.path_to_tif = '/Users/pb/Data/PBLab/David/WideField_GCamP6/#2_vasc_occ_RH/stim_left.tif';
prmts.concatenate_files = 0; % 0 or 1. If set to 1, specify full path in cell array here belopw; path_to_tif can be empty in this case.
prmts.file_parts{1} = '/Users/pb/Data/PBLab/David/WideField_GCamP6/#2_vasc_occ_RH/stim_right.tif';
% prmts.file_parts{2} = '';

prmts.corrupted_header = 1; % use work around for files w/o timestamp data
%% Acq parameters

%trial parameters - empty if no trial structure 
prmts.fps = 34;
prmts.n_trials = 6; % this is the number of trial / condition. Notice that in this file there where 20 trials - have to delete in between conditions
prmts.n_stim_frames = 68;
prmts.n_pre_frames = 34;
prmts.n_post_frames = 204;
prmts.channels = struct('channel_number',1,'channel_name','GCaMP'); %add more channels as needed
prmts.cut_trials_out = 1; %indicates that trials have to be removed between conditions (this happens as changing experimental conditions is not instantaneous

%% Experiment parameters
%Experiments are hierarchically organized into conditions -> trials/continuous -> frames. 

prmts.experiment_type = 'trial_based'; %'trial_based' or 'continuous'

%conditions defined as structure with fields condition_name and condition_frame_range.
%At leaset one condition must be defined
conditions = struct('condition_name',[],'condition_frame_range',[]); 
conditions(1).condition_name = 'occ_off';
conditions(1).condition_frame_range = [1 1836];
conditions(2).condition_name = 'occ_on';
conditions(2).condition_frame_range = [2143 3978];
conditions(3).condition_name = 'occ_off';
conditions(3).condition_frame_range = [4285 6120];



prmts.conditions = conditions;