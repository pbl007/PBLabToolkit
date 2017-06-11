%% Loop through files to create the folder structure 
for idx = 1:length(files) 
    % Get file placement in folder tree 
    curFullFilename = files(idx).filename; 
    id = regexpi(curFullFilename, [filesep '(\d+)'], 'tokens'); 
    files(idx).id = id{1}{1}; 
    condition = regexpi(curFullFilename, '\d+_([a-zA-Z]{3,5})_DAY', 'tokens'); 
    files(idx).condition = condition{1}; 
    files(idx).day = regexpi(curFullFilename, 'DAY_\d+', 'match'); 
    files(idx).exp = regexpi(curFullFilename, '(EXP_S[a-zA-Z]{3,4})', 'match'); 
    files(idx).fov = regexpi(curFullFilename, '(FOV_\d{1,2})', 'match'); 
     
    % Save the files with the newly-created variables, and copy the analog 
    % channels to the corresponding folder 
    filepath = fullfile(foldername, 'results', files(idx).id, files(idx).condition, ... 
                        files(idx).day, files(idx).exp, files(idx).fov); 
    mkdir(filepath{1}); 
    try 
        copyfile([files(idx).folder, filesep, '*', files(idx).fov{1}, '*analog.txt'], filepath{1}); 
    catch 
        continue; 
    end 
end