function [data_struct] = widefield_toolkit__movie_continuous(data_struct,job_def)
%widefield_toolkit__parse_trials data to movie, uses first second as baseline



load(job_def.global_prmts.ref_allen_file_name);
sec_baseline = job_def.global_prmts.baseline_time_sec_cont;

%% determine frame id with stim

%% Convert to df/f by means of substracting the mode then normalizeing by the mode
%treat conditions
n_conditions = numel(job_def.exp_prmts.conditions);
figure('Name','Condition mode movie')
[path_to_file,file_base_name] = fileparts(job_def.exp_prmts.file_parts{1});

baseline_frames  = 1 : job_def.exp_prmts.fps * sec_baseline;
for cond_i = 1 : n_conditions
    
    cond_name = job_def.exp_prmts.conditions(cond_i).condition_name;
    this_movie_name = sprintf('%s_cond[%d][%s].avi',file_base_name,cond_i,cond_name);
    
    %% generate movie for current condition
   
    
    this_mov_data = mean(data_struct(cond_i).data_transformed,4);
    baseline_mean = squeeze(mean(this_mov_data(:,:,baseline_frames),3));
    dF = (this_mov_data-baseline_mean)./baseline_mean;
    dF(isnan(dF))=0;
    n_frames = size(dF,3);
    t_sec = data_struct(cond_i).t_msec/1000;
    % Create animation.
    
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
%         if ismember(frame_i,stim_on_frame_idx)
%             h_rect = rectangle('Position',[10,10,20,20]);
%             set(h_rect,'facecolor','r')
%         end
        set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])
        crameri('berlin');
        axis image
        caxis ([-0.05 0.05]);colorbar;
        hold off
        
        %add timmer
        text(280,10,sprintf('%3.3f',t_sec(frame_i)),'color',[0.7 0.7 0.7],'FontSize',18);
        drawnow
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
    end
    
    % Close the file.
    close(vidObj);
end


