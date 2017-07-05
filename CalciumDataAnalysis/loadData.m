function compiled = loadData(files, filepaths, header)
% Load into memory the .mat files saved in the located the files variable
% specifies.

compiled = struct('animalID', [], 'conditionID', [], 'dataFileName', [],...
                 'daysAfterBaseline', [], 'experimentType', [], 'FOV', [], ...
                 'fps', [], 'maxProjImg', [], 'Coor', [], 'C_df', [], ...
                 'S_or', [], 'stimVector', [], 'speedVector',[], ...
                 'S_or_run_stim',[], 'S_or_run_spont', [], 'S_or_run_juxta', [], ...
                 'S_or_stand_stim', [], 'S_or_stand_spont', [], 'S_or_stand_juxta', [], ...
                 'C_df_run_stim',[], 'C_df_run_spont', [], 'C_df_run_juxta', [],  ...
                 'C_df_stand_stim', [], 'C_df_stand_spont', [], 'C_df_stand_juxta', []);

for idx = 1:size(filepaths, 1)
    load(filepaths(idx));
    compiled(idx).dataFileName = files(idx).filename;
    compiled(idx).Coor = Coor;
    compiled(idx).S_or = S_or;
    compiled(idx).C_df = C_df;
    compiled(idx).Cn = Cn;
    compiled(idx).maxProjImg = compiled.Cn;
    compiled(idx).fps = header.fps;
    compiled(idx).animalID = files(idx).id;
    compiled(idx).conditionID = files(idx).condition;
    compiled(idx).daysAfterBaseline = files(idx).days;
    compiled(idx).experimentType = files(idx).exp;
    compiled(idx).FOV = files(idx).fov;
    
    %% Get analog
    ptr2mat = dir(char(filepaths(idx)));
    analogFilename = dir([ptr2mat.folder, filesep, '*_analog.txt']);

    if isempty(ptr2mat)
        warning('No Analog1 data here...')
    else
        stimAndSpeed = load([analogFilename.folder, filesep, analogFilename.name]);
        compiled(idx).speedVector = stimAndSpeed(:, 2);
        compiled(idx).stimVector = stimAndSpeed(:, 1);
    end
    
end
fprintf('Finished gathering Calcium files.\n');
end