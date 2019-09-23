function data_struct = widefield_toolkit__load_data(job_def)
%function loads data, bins / crop if needed.
%Function returns data structure containing data for each condition


%% parse input -
%To make it code more compact, we will assume dataset is always broken into parts defined
%by multiple files, path_to_tif will be cell array, each entry pointing to a differnt file

if ischar(job_def)
    path_to_tif = {job_def};
elseif isstruct(job_def)
    %check if file is broken into parths
    
    path_to_tif = job_def.exp_prmts.file_parts;
    
else
    error('Input must be string or job_def structure');
end


%% read

%% extract header and timestamps
n_parts = numel(path_to_tif);
n_frames = numel(job_def.exp_prmts.t_msec);
n_frames_in_parts = job_def.exp_prmts.n_frames_in_parts;

nr = ceil(job_def.exp_prmts.ori_im_size(1)/job_def.global_prmts.binning_factor);
nc = ceil(job_def.exp_prmts.ori_im_size(2)/job_def.global_prmts.binning_factor);
data = zeros(nr,nc,n_frames,'uint16');

%We might need to load and process frame-by-frame
if job_def.global_prmts.memory_safe || job_def.global_prmts.binning_factor>1
    
    %%
    part_idx_offset = 0;
    for part_i = 1 : n_parts
        
        
        for frame_i = 1 : n_frames_in_parts(part_i)
            this_frame = imread(path_to_tif{part_i},frame_i);
            this_frame_binned = imresize(this_frame,1/job_def.global_prmts.binning_factor);
            data(:,:,frame_i+part_idx_offset) = this_frame_binned;
        end %frames
        part_idx_offset = n_frames_in_parts(part_i);
        
    end%parts
else
    data = loadmovie(path_to_tif{1});
end

%% break data into conditions
data_struct = struct('condition_id',[],'condition_name',[],'frame_range',[],'t_msec',[],'data',[]);
n_conditions = numel(job_def.exp_prmts.conditions);
for cond_i = 1 : n_conditions
    data_struct(cond_i).condition_id = cond_i;
    data_struct(cond_i).condition_name = job_def.exp_prmts.conditions(cond_i).condition_name;
    frame_range = job_def.exp_prmts.conditions(cond_i).condition_frame_range;
    data_struct(cond_i).frame_range = frame_range;
    data_struct(cond_i).t_msec = job_def.exp_prmts.t_msec(frame_range(1):frame_range(2));
    data_struct(cond_i).data = data(:,:,frame_range(1):frame_range(2));
end

