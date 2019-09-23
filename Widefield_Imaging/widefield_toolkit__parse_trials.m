function [data_struct] = widefield_toolkit__parse_trials(data_struct,job_def)
%widefield_toolkit__parse_trials parses time series based on the nubmer of trials

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
subplot(n_conditions,3,1);% we will plot each condition/row then mean pre, stim and post frames along columns
plot_row = 1;

[nr,nc] = size(data_struct(1).data_transformed(:,:,1));

sec_baseline = sec_baseline = job_def.global_prmts.baseline_time_sec_trial;
baseline_frames  = 1 : job_def.exp_prmts.fps * sec_baseline;

for cond_i = 1 : n_conditions
    
    %compute trial averaged
    n_frames_per_trial = (n_pre_frames+n_stim_frames+n_post_frames)/n_channels;
    data_struct(cond_i).data_transformed = reshape(data_struct(cond_i).data_transformed,nr,nc,n_frames_per_trial,n_trials);
    
    subplot(n_conditions,3,plot_row)
    first_frame = 1;
    last_frame = n_pre_frames;
    pre = data_struct(cond_i).data_transformed(:,:,first_frame:last_frame,:);
   
    pre = mean(pre,4);%average over trials and over frames
    
    baseline=mean(pre(:,:,baseline_frames),3);
    pre = mean(pre,3);
    this_im = (pre-baseline)./baseline;
    this_im(isnan(this_im))=0;
    imagesc(this_im)
    colorbar
    title('Pre')
    crameri('berlin');
    caxis ([-0.05 0.05]);colorbar;
    set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])
    axis image

    
    if cond_i==1
        caxis_vals = caxis;
    end
    
    
    subplot(n_conditions,3,plot_row+1)
    first_frame = last_frame + 1;
    last_frame = n_pre_frames+n_stim_frames;
    stim = data_struct(cond_i).data_transformed(:,:,first_frame:last_frame ,:);
    stim = mean(mean(stim,4),3);%average over trials and over frames
    this_im = (stim-pre)./pre;
    this_im(isnan(this_im))=0;
    imagesc(this_im)
    % caxis(caxis_vals);
    colorbar
    title('(Stim-Pre)/Pre')
    crameri('berlin');
    caxis ([-0.05 0.05]);colorbar;
    set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])
    axis image
    
    
    subplot(n_conditions,3,plot_row+2)
    first_frame = last_frame + 1;
    last_frame = n_pre_frames + n_stim_frames + n_post_frames;
    post = data_struct(cond_i).data_transformed(:,:,first_frame:last_frame ,:);
    post = mean(mean(post,4),3);%average over trials and over frames
    %    caxis(caxis_vals);
    this_im = (post-pre)./pre;
    this_im(isnan(this_im))=0;
    imagesc(this_im)
    colorbar
    title('(Post-Pre)/Pre')
    crameri('berlin');
    caxis ([-0.05 0.05]);colorbar;
    set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])
    axis image
    
    plot_row = plot_row + 3;
    
    
end

