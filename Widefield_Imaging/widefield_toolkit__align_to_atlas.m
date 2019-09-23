Kxfunction [data_struct,reg_prmts] = widefield_toolkit__align_to_atlas(data_struct,job_def)
%widefield_toolkit__align_to_atlas brings mapping to tool to allow user to select anchor
%points for registering to Allen (or other) reference atlas. Function appends a new
%field with transformed data to each conditions and stores transform details in the
%experiment parameter structure of the job_def.
%
%Pablo - Apr 2019


user_is_happy_with_registration = 0;
max_reg_attempts = 3;

source_movie_avg = uint16(squeeze(mean(mean(data_struct(1).data,3),4)));
load(job_def.global_prmts.ref_allen_file_name); %load allen_2d_cortex_map and allen_2d_cortex_rois
%% Alight to reference map

attempt_counter = 1;

%check if registration was already performed and attemp to use existing variable
if isfield(job_def,'reg_prmts')
    movingPoints = job_def.reg_prmts.movingPoints;
    fixedPoints = job_def.reg_prmts.fixedPoints;
end

while ~user_is_happy_with_registration && attempt_counter < max_reg_attempts
    % here you need to manually choose -at least - 11 points of registration.
    % After choosing press file and then export to workspace
    %     clear fixedPoints movingPoints
    
    if exist('movingPoints','var')
        [movingPoints,fixedPoints] = cpselect(imadjust(source_movie_avg,stretchlim(source_movie_avg,0.2)),uint16(allen_2d_cortex_map)*2^16,...
            movingPoints,fixedPoints,'Wait',true);%the first is modified to match the second
    else
        [movingPoints,fixedPoints] = cpselect(imadjust(source_movie_avg,stretchlim(source_movie_avg,0.2)),uint16(allen_2d_cortex_map)*2^16,...
            'Wait',true);%the first is modified to match the second
    end
    
    %% compute transform and display
    tform = fitgeotrans(movingPoints,fixedPoints,'polynomial',3);
    %tform = cp2tform(movingPoints(:,:),fixedPoints(:,:), 'nonreflective similarity');
    target_image_transformed = imwarp(source_movie_avg,tform,'OutputView',imref2d(size(allen_2d_cortex_map))); %aligned map
    
    %%
    
    figure('Name',sprintf('Registration results - attempt %d/%d',attempt_counter,max_reg_attempts));
    imshowpair(allen_2d_cortex_map,target_image_transformed);
    h_to_push_done = uicontrol(gcf,'Style','pushbutton','callback','evalin("caller","user_is_happy_with_registration=1;close(gcf);return;")','String','Done!');
    waitfor(h_to_push_done)
    attempt_counter = attempt_counter + 1;
end

%% if user happy


%treat conditions
n_conditions = numel(job_def.exp_prmts.conditions);

for cond_i = 1 : n_conditions
    
    % transform eahc frame, save as new tif
    n_frames = size(data_struct(cond_i).data,3);
    [nr, nc] = size(target_image_transformed);
    data_struct(cond_i).data_transformed = zeros([nr nc n_frames],'uint16');
    for frame_i = 1 : n_frames
        data_struct(cond_i).data_transformed (:,:,frame_i)= imwarp(data_struct(cond_i).data(:,:,frame_i),tform,'OutputView',imref2d(size(allen_2d_cortex_map))).*crystal_skull_mask;
    end
end

reg_prmts.tform = tform;
reg_prmts.movingPoints = movingPoints;
reg_prmts.fixedPoints = fixedPoints;

