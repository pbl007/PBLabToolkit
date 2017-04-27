% Save all files in the files struct in their suitable folder to create 
% the correct folder structure

%% Loop through files and save them
for idx = 1:length(files)
    % Get file placement in folder tree
    curFullFilename = files(idx).filename;
    id = regexp(curFullFilename, [filesep '(\d+)'], 'tokens');
    files(idx).id = id{1}{1};
    condition = regexp(curFullFilename, '\d+_([a-zA-Z]{3,5})_DAY', 'tokens');
    files(idx).condition = condition{1};
    files(idx).day = regexp(curFullFilename, 'DAY_\d+', 'match');
    files(idx).exp = regexp(curFullFilename, '(EXP_[a-zA-Z]{4,5})', 'match');
    files(idx).fov = regexp(curFullFilename, '(FOV_\d{1,2})', 'match');
    
    % Create the relevant variables to save
    S_or = S_us{idx};
    F_Df = F_df{idx};
    C_df = C_us{idx};
    P_or = P_us{idx};
    FO = F0{idx};
    Fd_or = Fd_us{idx};
    dataFileName = files(idx).filename;
    fps = 1 / mean(diff(header(idx).frameTimestamps_sec(1:2:end)));
    
   
    
    % Save the files with the newly-created variables, and copy the analog
    % channels to the corresponding folder
    filepath = fullfile(foldername, 'results', files(idx).id, files(idx).condition, ...
                        files(idx).day, files(idx).exp, files(idx).fov);
    mkdir(filepath{1});
    save([filepath{1}, filesep, id{1}{1} '_data.mat'], 'Coor', 'S_or', ...
         'F_Df', 'C_df', 'P_or', 'F0', 'Fd_or', 'dataFileName', 'Cn', ...
         'fps', '-v7.3');
    copyfile([files(idx).folder, filesep, '*', files(idx).fov{1}, '*analog.txt'], filepath{1});
end
