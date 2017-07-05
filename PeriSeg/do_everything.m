function [seeds_cc]=do_everything(filename, workingDir, perycyte_max_size)
%%
% Needed files:
% MergedCellCentroids from vida
% Vascenhanced mask from vida
%raw_ch1 and 3 
% Matlab fiels:
% essential_pre_processing
%thresholding_ch1
%extract_perycytes_for_machine
%extract_pericytes_for_gui
%%
str=sprintf('%s/%s-VascEnhancedMask.mat',workingDir, filename);
load(fullfile(workingDir, 'MergedCellCentroids.mat'));
load(str);
raw_ch1_filename=sprintf('%s/%s-Ch1.tif',workingDir, filename);
raw_ch3_filename=sprintf('%s/%s-Ch3.tif',workingDir, filename);

raw_ch1=readTiff3D(raw_ch1_filename);
raw_ch3=readTiff3D(raw_ch3_filename);
[cleaned_seeds_mat,filtered_ch1,vasc_enh_mat]=essential_pre_processing(vascEnhancedMask,mergedcclist,raw_ch1);
thresholded_ch1=thresholding_ch1(raw_ch1,raw_ch3,vasc_enh_mat);
[seeds_cc,begin_centroids]=segmentation_p(cleaned_seeds_mat,thresholded_ch1);
%extract_perycytes_for_machine(seeds_cc,perycyte_max_size,filename_prefix_for_mask,filename_prefix_for_label)
extract_perycytes_for_gui(seeds_cc,begin_centroids,raw_ch1,raw_ch3,'./gui5/seed')
save(fullfile(workingDir, 'seeds_cc.mat'), seeds_cc);
end