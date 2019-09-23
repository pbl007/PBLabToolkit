function [data_struct] = widefield_toolkit__trial_analyze(data_struct,job_def)
%widefield_toolkit__trial_analyze parses time series based on the nubmer of trials and
%computes stats
%

%% get trial parameters
n_pre_frames = job_def.exp_prmts.n_pre_frames;
n_stim_frames = job_def.exp_prmts.n_stim_frames;
n_post_frames = job_def.exp_prmts.n_post_frames;
n_trials = job_def.exp_prmts.n_trials;
n_channels = numel(job_def.exp_prmts.channels);
n_conditions = numel(job_def.exp_prmts.conditions);
expected_num_frames = n_channels * n_trials * (n_pre_frames+n_stim_frames+n_post_frames) * n_conditions;
% n_frames = size(data,3);
% if expected_num_frames ~= n_frames
%     error_msg = sprintf('The number of frames in the data does not match the expected number of frames.');
%     error_msg = [error_msg sprintf('\nThe data has %d frames and we expected %d',n_frames,expected_num_frames)];
%     error_msg = [error_msg sprintf('\nn_pre_frames=%d\nn_stim_frames=%d',n_pre_frames,n_stim_frames)];
%     error_msg = [error_msg sprintf('\nn_post_frames=%d\nn_trials=%d',n_post_frames,n_trials)];
%     error_msg = [error_msg sprintf('\nn_channels=%d\nn_conditions=%d',n_channels,n_conditions)];
%     error_msg = [error_msg sprintf('\nCheck tthe definitions in %s',job_def.prmt_file)];
%     error(error_msg);
% end

%% if nChannel > 1 deinterleave
% if n_channels>1
%     %not implemented - need definition for fluo/reflectance channels
% else
%     thisChannel =1;
% end
% [nr,nc,nf] = size(data);
% data = reshape(data,nr,nc,n_channels,nf/n_channels);
% size(data)
%% Convert to df/f by means of substracting the mode then normalizeing by the mode
%treat conditions
n_conditions = numel(job_def.exp_prmts.conditions);
figure('Name','Condition mode map','windowStyle','docked')
for cond_i = 1 : n_conditions
    fprintf('\nComputing image mode');
    % M = uint16(mean(squeeze(data(:,:,thisChannel,:)),3));
    M = uint16(mean(data_struct(cond_i).data,3));
    subplot(1,n_conditions,cond_i); imagesc(M);title (data_struct(cond_i).condition_name);axis image;colorbar;drawnow
    data_struct(cond_i).mode_img = M;
    
    %%
    %compute trial averaged
    n_frames_per_trial = (n_pre_frames+n_stim_frames+n_post_frames)/n_channels;
    data_struct(cond_i).data = reshape(data_struct(cond_i).data,nr,nc,n_frames_per_trial,n_trials);
    data_struct(cond_i).trial_avg_mod_substracted = mean(data_struct(cond_i)-M.data,4);
    
end
%% display
for i_frame = 1 : n_frames_per_trial
    imagesc(squeeze(trial_avg(:,:,i_frame)));
    title(num2str(i_frame))
    axis image
    colorbar
    drawnow;
    
end


