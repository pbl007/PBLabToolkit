function [data_struct] = widefield_toolkit__parse_trials(data_struct,job_def)
%widefield_toolkit__parse_trials parses time series based on the nubmer of trials

%% get trial parameters
n_pre_frames = job_def.exp_prmts.n_pre_frames;
n_stim_frames = job_def.exp_prmts.n_stim_frames;
n_post_frames = job_def.exp_prmts.n_post_frames;
n_trials = job_def.exp_prmts.n_trials;
n_channels = numel(job_def.exp_prmts.channels);
n_conditions = numel(job_def.exp_prmts.conditions);
% expected_num_frames = n_channels * n_trials * (n_pre_frames+n_stim_frames+n_post_frames) * n_conditions;

load(job_def.global_prmts.ref_allen_file_name);
%% if nChannel > 1 deinterleave
% if n_channels>1
%     %not implemented - need definition for fluo/reflectance channels
% else
%     thisChannel =1;
% end
% [nr,nc,nf] = size(data);
% data = reshape(data,nr,nc,n_channels,nf/n_channels);
% size(data)

%% determine frame id with stim
stim_frames = (1 : n_stim_frames)+ n_pre_frames;
frame_duration_msec = 1/job_def.exp_prmts.fps*1000;
n_frames_delay = ceil(job_def.exp_prmts.stim_delay_msec/frame_duration_msec);
n_frames_stim = ceil(job_def.exp_prmts.stim_duration_msec/frame_duration_msec);
n_frames_interval = ceil(job_def.exp_prmts.stim_interval_msec/frame_duration_msec);
%build logical vector with ones for stim on frames
stim_block = [zeros(1,n_frames_delay) ones(1,n_frames_stim) zeros(1,n_frames_interval)];
n_stim_frames = length(stim_frames);
n_stim_block_frames = length(stim_block);
%appent blocks, trim to n_stim_frames
idx = logical(repmat(stim_block,1,ceil(n_stim_frames/n_stim_block_frames)));
stim_on_frame_idx = stim_frames(idx(1:n_stim_frames));
%% Convert to df/f by means of substracting the mode then normalizeing by the mode
%treat conditions
n_conditions = numel(job_def.exp_prmts.conditions);
figure('Name','Condition mode movie','windowStyle','docked')
[path_to_file,file_base_name] = fileparts(job_def.exp_prmts.file_parts{1});
for cond_i = 1 : n_conditions
    
    cond_name = job_def.exp_prmts.conditions(cond_i).condition_name;
    this_movie_name = sprintf('%s_cond[%d][%s].avi',file_base_name,cond_i,cond_name);
    
    %% generate movie for current condition
    baseline_frames  = 1 : 34;
    
    this_mov_data = mean(data_struct(cond_i).data_transformed,4);
    baseline_mean = squeeze(mean(this_mov_data(:,:,baseline_frames),3));
    dF = (this_mov_data-baseline_mean)./baseline_mean;
    dF(isnan(dF))=0;
    n_frames = size(dF,3);
    % Create an animation.
    
    imagesc(squeeze(dF(:,:,1)));
    axis image
    axis on
    box on
    set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])
    set(gca,'nextplot','replacechildren');
    
    
    % Prepare the new file.
    vidObj = VideoWriter(fullfile(path_to_file,this_movie_name));
    open(vidObj);
    for frame_i = 1:n_frames
        imagesc(squeeze(dF(:,:,frame_i)));
        
        %add hemisphere countours
        hold on
        plot(left_hemisphere_coor(:,1),left_hemisphere_coor(:,2),'w-')
        plot(right_hemisphere_coor(:,1),right_hemisphere_coor(:,2),'w-')
        if ismember(frame_i,stim_on_frame_idx)
            h_rect = rectangle('Position',[10,10,20,20]);
            set(h_rect,'facecolor','r')
        end
        set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])
        crameri('berlin');
        axis image
        caxis ([-0.05 0.05]);colorbar;
        hold off
        drawnow
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
    end
    
    % Close the file.
    close(vidObj);
end


