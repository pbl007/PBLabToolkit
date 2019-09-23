%% Analyze
clc
clear
clf
fprintf('Analyzing wide field data');
%%
addpath('/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging');
addpath('/Users/pb/Dropbox/__MATLAB/PBLabToolkit/External/crameri_v1.05/crameri');
analysis_prmts.ref_allen_file_name = '/Users/pb/Dropbox/__MATLAB/PBLabToolkit/Widefield_Imaging/BuildingInteractiveMask/allen_2d_cortex_regions_crystal_skull.mat';
analysis_prmts.analyzed_data_dir = '/Users/pb/Data/David/all_vascular_occluder-widefield/Analyzed_Data';
analysis_prmts.results_data_dir = '/Users/pb/Data/PBLab/David/WideField_GCamP6/collected_results';
analysis_prmts.fig_dir = '/Users/pb/Data/PBLab/David/WideField_GCamP6/figures';
%analysis related
analysis_prmts.baseline_time_sec_cont = 20;
analysis_prmts.window_size_sec = 20;
analysis_prmts.window_overlap_sec = 1;

analysis_prmts.baseline_time_sec_trial = 0.5;
analysis_prmts.window_size_sec_trial = 1;
analysis_prmts.window_overlap_sec_trial = 0.1;

load(analysis_prmts.ref_allen_file_name)
analysis_prmts.roi_struct = allen_2d_cortex_rois;



if ~isdir(analysis_prmts.results_data_dir);mkdir(analysis_prmts.results_data_dir);end
%% define job



%% Spont defs
% job_i = 0;
% job_i = job_i + 1;
% analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#1_spont_no_vasc_occ_1_min_bin.mat';
% analysis_job(job_i).group = 'Spont no occ';
%
% job_i = job_i + 1;
% analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#1_spont_occ_1_min_bin.mat';
% analysis_job(job_i).group = 'Spont occ';
%
% job_i = job_i + 1;
% analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#2_spont_no_occ_1min_bin.mat';
% analysis_job(job_i).group = 'Spont no occ';
%
% job_i = job_i + 1;
% analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#2_spont_occ_1min_bin.mat';
% analysis_job(job_i).group = 'Spont occ';
%
% job_i = job_i + 1;
% analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#3_spont_no_occ_1min_bin.mat';
% analysis_job(job_i).group = 'Spont no occ';
%
% job_i = job_i + 1;
% analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#3_spont_occ_1min_bin.mat';
% analysis_job(job_i).group = 'Spont occ';


%% Stim defs
job_i = 0;

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#1_stim_left_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#1_stim_right_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#2_stim_left_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#2_stim_right_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#3_stim_left_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#3_stim_right_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#5_stim_left_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

job_i = job_i + 1;
analysis_job(job_i).source_data = '/Users/pb/Data/PBLab/David/WideField_GCamP6/Analyzed_Data/#5_stim_right_bin.mat';
analysis_job(job_i).group = 'Stim left occ';

%% run analysis job
n_jobs = numel(analysis_job);

for job_i=1:n_jobs
    fprintf('\nLoading ROI data for job %d',job_i)
    load(analysis_job(job_i).source_data)
    analysis_job(job_i).global_prmts = this_job_def.global_prmts;
    [~,base_name] = fileparts(analysis_job(job_i).source_data);
    
    fprintf('\tDone');
    %% extract roi data if missing from this_job_def
    if ~isfield(data_struct,'roi_struct')
        
        fprintf('\nExtracting ROI data')
        load(analysis_prmts.ref_allen_file_name)
        analysis_job(job_i).roi_struct = allen_2d_cortex_rois;
        analysis_job(job_i).exp_prmts = this_job_def.exp_prmts;
        
        data_struct = widefield_toolkit__extract_roi_data(data_struct,analysis_job(job_i));
        fprintf('\tDone');
        
        fprintf('\nSaving data for job %d',job_i);
        save(analysis_job(job_i).source_data,'this_job_def','data_struct','-V7.3')
        fprintf('\tDone');
    end
    
    %% Compute sliding corr matrix.
    figure('Name',base_name,'windowstyle','docked')
    n_cond = numel(data_struct);
    if n_cond>1
        
        tmp =[];
            t=data_struct(1).t_msec/1000;
        for cond_i = 1 : n_cond
            this_cond_data = [data_struct(cond_i).roi_struct.mean_frame_data];
            
        
            ti = 1:size(this_cond_data,1);
            
            subplot(3,n_cond,cond_i)
            plot(t(ti),this_cond_data(:,1:28))
            xlabel('Time (sec)')
            ylabel('df/f')
            set(gca,'linewidth',0.5)
            axis square
            
            subplot(3,n_cond,cond_i+n_cond)
            plot(t(ti),this_cond_data(:,29:end))
            xlabel('Time (sec)')
            ylabel('df/f')
            set(gca,'linewidth',0.5)
            axis square
            
            subplot(3,n_cond,cond_i+n_cond*2)
            R_cond = corrcoef(this_cond_data);
            imagesc(R_cond);axis square
            caxis([-1 1])
                set(gca,'xticklabel',[],'xtick',[],'yticklabel',[],'ytick',[])

            crameri('berlin')
            
            
            
            tmp = [tmp;this_cond_data];
        end
       
        export_fig(fullfile(analysis_prmts.fig_dir,[base_name '.eps']))

        all_roi_dF = tmp;
        
    else
        all_roi_dF=[data_struct.roi_struct.mean_frame_data];
    end
    n_rois = size(all_roi_dF,2);
    %
    % %compute cross correlation coefficient for current window
    n_frames = size(all_roi_dF,1);
    
    
    if strcmp(this_job_def.exp_prmts.experiment_type,'trial_based')
        window_size_sec =  analysis_prmts.window_size_sec_trial;
        window_overlap_sec = analysis_prmts.window_overlap_sec_trial;
    else
        window_size_sec = 20;
        window_overlap_sec = 0.5;
        
        
        
        
        window_size_frames = ceil(window_size_sec * this_job_def.exp_prmts.fps);
        window_overlap_frames = ceil(window_overlap_sec * this_job_def.exp_prmts.fps);
        
        window_start = 1:window_overlap_frames:n_frames;
        window_stop = window_start+window_overlap_frames;
        
        window_stop(end)=n_frames;
        
        n_windows = numel(window_start);
        R=zeros(n_rois,n_rois,n_windows);
        
        %keep in vector from all ements of the top triangle of the correlation matrix as
        %"fingerprint" of current network state
        R_fingerprint = zeros(n_rois*(n_rois-1)/2,n_windows);
        triu_i = triu(ones(n_rois,n_rois),1);
        triu_i_idx = triu_i(:)>0;
        for window_i = 1 : n_windows
            this_R = corrcoef(all_roi_dF(window_start(window_i):window_stop(window_i),:));
            R(:,:,window_i) = this_R;
            %
            R_fingerprint(:,window_i) = this_R(triu_i_idx);
            %     imagesc(squeeze(R(:,:,window_i)))
            
            crameri('berlin');
            drawnow
        end
        
        % compute correlation coefficient between consequtive windows
        R_fingerprint_corr = diag(corrcoef(R_fingerprint),1);
        analysis_job(job_i).t_sec = window_start/this_job_def.exp_prmts.fps;
        analysis_job(job_i).R = R;
        analysis_job(job_i).R_fingerprint = R_fingerprint;
        analysis_job(job_i).R_fingerprint_corr = R_fingerprint_corr;
    end %experiment type
end

%%
res_name = sprintf('widefield_collected_results_%s',datestr(now,'YYYYMMDD_hhmmss'));
path_to_res = fullfile(analysis_prmts.results_data_dir,res_name);
fprintf('\nSaving collected results to %s',path_to_res)
save(path_to_res,'analysis_job')
fprintf('\tDone');


%% Plot
t = analysis_job(1).t_sec;
figure
R = [analysis_job.R_fingerprint_corr];
% plot(R,'o')
% hold on
M = movmedian([analysis_job.R_fingerprint_corr],4);

n_plots = 4
for plot_i = 1 : n_plots
    subplot(n_plots,1,plot_i)
    plot(t(1:end-1),R(:,[1 2]+(plot_i-1)*2),'-','LineWidth',4)
    
    xlabel('Time(s)')
    ylabel('Corr Coeff','FontSize',24)
end

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

