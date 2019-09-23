function data_struct = widefield_toolkit__extract_roi_data(data_struct,job_def)
%widefield_toolkit__extract_roi_data cycles through the roi_struct structure array and
%extracts for each roi the average signal from the data 3D timeseries.
%
%INPUTS
%data           full path to the data or a 3D matrix (r x c x t  (movie))
%roi_struct     structure array, function looks for .PixelIDList field
%
%OUTPUT
%roi_struct     populated with a new field .mean_frame_data

%% decide what type of input we got for data
if ischar(data_struct)
    data_struct.data = loadmovie(data_struct);
    
end

%compute dF
if strcmp(job_def.exp_prmts.experiment_type,'trial_based')
    sec_baseline = job_def.global_prmts.baseline_time_sec_trial;
else
    sec_baseline = job_def.global_prmts.baseline_time_sec_cont;
end
roi_struct = job_def.roi_struct;


%% Convert to df/f by means of substracting the mode then normalizeing by the mode
%treat conditions
n_conditions = numel(job_def.exp_prmts.conditions);

baseline_frames  = 1 : job_def.exp_prmts.fps * sec_baseline;
%% cycle rois, extract and take the mean data pixel, populate new field
n_rois = numel(roi_struct);
for cond_i = 1 : n_conditions
    
    cond_name = job_def.exp_prmts.conditions(cond_i).condition_name;
    
    
    n_time_frames = size(data_struct(cond_i).data_transformed,3);
    data = mean(data_struct(cond_i).data_transformed,4);
    baseline_mean = squeeze(mean(data(:,:,baseline_frames),3));
    
    
    roi_struct = job_def.roi_struct;
    
    
    dF = (data-baseline_mean)./baseline_mean;
    dF(isnan(dF))=0;
    n_time_frames = size(dF,3);
    t_sec = data_struct(cond_i).t_msec/1000;
    
    for i_roi = 1 : n_rois
        this_roi_pixel_id_list = roi_struct(i_roi).PixelIdxList;
        x = zeros(n_time_frames,1);
        for i_frame = 1 : n_time_frames
            this_frame = squeeze(dF(:,:,i_frame));
            x(i_frame)  = mean(this_frame(this_roi_pixel_id_list));
        end
        roi_struct(i_roi).mean_frame_data = x;
    end
    data_struct(cond_i).roi_struct = roi_struct;
end%conditions