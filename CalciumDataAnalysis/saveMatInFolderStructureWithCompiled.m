% Save all files in the files struct in their suitable folder with 
% EP_FILES_COMPILED

%% Loop through files and save them
for idx = 1:length(files)
   
    % Create the relevant variables to save
    S_or = S_us{idx};
    F_Df = F_df{idx};
    C_df = C_us{idx};
    P_or = P_us{idx};
    FO = F0{idx};
    Fd_or = Fd_us{idx};
    coorKeep = Coor(keep);
    compiled = EP_FILES_COMPILED(idx);
    dataFileName = files(idx).filename;
    fps = 1 / mean(diff(header(idx).frameTimestamps_sec(1:2:end)));
    
   
    
    %% Save the files with the newly-created variables, and copy the analog
    % channels to the corresponding folder
    filepath = fullfile(foldername, 'results', files(idx).id, files(idx).condition, ...
                        files(idx).day, files(idx).exp, files(idx).fov);
                    
    save([filepath{1}, filesep, id{1}{1} '_data_with_compiled.mat'], 'Coor', 'S_or', ...
         'F_Df', 'C_df', 'P_or', 'F0', 'Fd_or', 'dataFileName', 'Cn', ...
         'fps', 'compiled', 'keep', 'folder_name', '-v7.3');
end
