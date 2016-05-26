function T = gatherRESfiles(path2sourceDir,path2groupledResults,groupedResultsFileName,variables2extract)
%funcitons browses set of input directories and gathers results into "database"
%
%Folder setup
%
%   animalID
%       |____ Condition 1
%       |____ Condition 2
%       |____ Condition 3
%       |____ Condition 4
%       |____ ....
%
% No need for specific naming, just file structure
%
% Usage: 
%   gatherRESfiles(source_dir,target_dir,[],{'radon_um_per_s','diameter_um '})
%
% Last updated Dec 2015


%find out number of "animal ID" folders

nAnimalIDs = numel(path2sourceDir);
clc

fprintf('Processing root data directory "%s" ',path2sourceDir);
%for each directory, find out how many conditions
dirContentAnimalIDLevel = dir(path2sourceDir);
valid = find([dirContentAnimalIDLevel.isdir]);
valid = valid(3:end);
dirContentAnimalIDLevel = dirContentAnimalIDLevel(valid);
numAnimalIds = numel(dirContentAnimalIDLevel);

%%
RES_FILES_COMPILED = struct('animalID',[],'conditionID',[],'RESfileName',[],'name',[],'varType',[],...
    'y_mean',[],'y_std',[],'y',[],'t',[],'freq',[]);

for iIDs = 1 : numAnimalIds
    
    fprintf('\n--->Aminal ID "%s"\t(%d/%d)',dirContentAnimalIDLevel(iIDs).name,iIDs,numAnimalIds);
    
    
    %figure out how many conditions for current animal ID
    path2CurrentAnimalID = fullfile( path2sourceDir,dirContentAnimalIDLevel(iIDs).name);
    dirContentCurrentAnimalID = dir(path2CurrentAnimalID);
    valid = find([dirContentCurrentAnimalID.isdir]);
    valid = valid(3:end);
    dirContentCurrentAnimalID = dirContentCurrentAnimalID(valid);
    numCurrentAnimalIDConditions = numel(dirContentCurrentAnimalID);
    
    %cycle conditions
    for iCOND = 1 : numCurrentAnimalIDConditions
        path2CurrentConditions = fullfile(path2CurrentAnimalID,dirContentCurrentAnimalID(iCOND).name);
        fprintf('\n\n\t--->Condition "%s"\t(%d/%d)',dirContentCurrentAnimalID(iCOND).name,iCOND,numAnimalIds);
        
        %cycle RES files in current conditions
        dirContentRESfiles = dir(fullfile(path2CurrentConditions,'RES*.mat'));
        dirContentRESfiles = dirContentRESfiles(~[dirContentRESfiles.isdir]);%avoid case of folder named RES-something
        nRESfiles = numel(dirContentRESfiles);
        if nRESfiles == 0
            fprintf('\n\t\t---> NO RES FILE!!!')
        else
            
            for iRES = 1 : nRESfiles
                fprintf('\n\t\t\t--->%s',dirContentRESfiles(iRES).name)
                path2RESfile = fullfile(path2CurrentConditions,dirContentRESfiles(iRES).name);
                data = getWorkspaceVars(path2RESfile,variables2extract);
                %add animal ID and condition
                [data.animalID] = deal(dirContentAnimalIDLevel(iIDs).name);
                if ~isempty(data(1).name)
                [data.conditionID] = deal(dirContentCurrentAnimalID(iCOND).name);
                [data.RESfileName] = deal(dirContentRESfiles(iRES).name);
                RES_FILES_COMPILED = [RES_FILES_COMPILED orderfields(data,{'animalID','conditionID','RESfileName','name','varType','y_mean','y_std','y','t','freq'})];
                else
                   fprintf('\t\t***** GOT NOT DATA FROM FILE - VARIABLES DID NOT MATCH PATTERN *****') 
                end
            end%cycling RES files
        end% got RES files
        
        
    end %cycling conditions (i.e. directoris inside animalID root directory)
    
end%cycling animal ids

fprintf('\nSaving data (.mat and .txt) to %s',path2groupledResults);
RES_FILES_COMPILED=RES_FILES_COMPILED(2:end);
T = struct2table(RES_FILES_COMPILED);
%writetable(T,fullfile(path2groupledResults,'ALL_RES_FILES.txt'))
save(fullfile(path2groupledResults,'ALL_RES_FILES.mat'),'RES_FILES_COMPILED')
