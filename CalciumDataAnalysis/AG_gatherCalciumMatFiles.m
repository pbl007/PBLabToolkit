function [EP_FILES_COMPILED] = AG_gatherCalciumMatFiles(path2sourceDir)
%funcitons browses set of input directories and gathers results into "database"
%
%30/8/16  AG removed path2sourceDir as an input and added uigetfile for
%this
% clearvars;
% path2sourceDir = uigetdir('*.*','select a mouse directory');

%Directory structure
%
%   animalID
%       |____ Condition where "Condition" is  (HYPO/HYPER x TAC/SHAM)
%           |____DAY_x //x is number - baseline is 0
%               |___ EXP_x //where x is  either STIM or SPONT (for spontaneous)
%                     |____ FOV_x // where x is 1 by default, must be
%                   present.
%       |____ Condition 2
%       |____ Condition 3
%       |____ Condition 4
%       |____ ....
%
% Must keep specific folder naming!
%
% Usage:
%   gatherRESfiles(source_dir,target_dir,[],{'radon_um_per_s','diameter_um '})
%
% Last updated Aug 2016



%find out number of "animal ID" folders
addpath('/data/MatlabCode/PBLabToolkit/External/altmany-export_fig-5be2ca4/export_fig.m');
fprintf('Processing root data directory "%s" ',path2sourceDir);
%for each directory, find out how many conditions
dirContentAnimalIDLevel = dir(path2sourceDir);
valid = find([dirContentAnimalIDLevel.isdir]);
valid = valid(3:end);
dirContentAnimalIDLevel = dirContentAnimalIDLevel(valid);
numAnimalIds = numel(dirContentAnimalIDLevel);

%%


dataRow = struct('animalID',[],'conditionID',[],'dataFileName',[],...
    'daysAfterBaseline',[],'experimentType',[],'FOV',[],'fps',[],...
    'maxProjImg',[],'Coor',[],'C_df',[],'S_or',[],'StimVector',[],'SpeedVector',[],...
    'run_stim',[],'run_no_stim',[],'stand_stim',[],'stand_no_stim',[]);

EP_FILES_COMPILED =[];

for iIDs = 1 : numAnimalIds
    
    fprintf('\n--->Aminal ID "%s"\t(%d/%d)',dirContentAnimalIDLevel(iIDs).name,iIDs,numAnimalIds);
    animalID = dirContentAnimalIDLevel(iIDs).name;
    
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
        fprintf('\n\t|-->Condition "%s"\t\t\t(%d/%d)',dirContentCurrentAnimalID(iCOND).name,iCOND,numAnimalIds);
        conditionID = dirContentCurrentAnimalID(iCOND).name;
        %figure out how many days for this Animal ID x Condition
        dirContentCurrentCond = dir([path2CurrentConditions filesep 'DAY_*']);
        
        if isempty(dirContentCurrentCond)
            warning('No DAY_x directory present - inconsistent tree')
        end
        
        %now cycle DAY_x folders in current condition
        numDAYsCurrentCond = numel(dirContentCurrentCond);
        for iDAY = 1 :numDAYsCurrentCond
            path2CurrentDAY = fullfile(path2CurrentAnimalID,dirContentCurrentAnimalID(iCOND).name,...
                dirContentCurrentCond(iDAY).name );
            fprintf('\n\t\t|-->DAY "%s"\t\t\t\t(%d/%d)',dirContentCurrentCond(iDAY).name,iDAY,numDAYsCurrentCond);
            
             daysAfterBaseline = dirContentCurrentCond(iDAY).name;
             daysAfterBaseline = str2double(daysAfterBaseline(strfind(dirContentCurrentCond(iDAY).name,'_')+1:end));
            %figure out how many experimental conditions - here we look for
            %"EXP_xxx"
            
            dirContentCurrentDAY = dir([path2CurrentDAY,filesep,'EXP_*']);
            if isempty(dirContentCurrentDAY)
                warning('No EXP_x directory present - inconsistent tree')
            end
            
            %cycle now experimental conditions
            numEXPinCurrentDAY = numel(dirContentCurrentDAY);
            for iEXP = 1 : numEXPinCurrentDAY
                path2CurrentEXP = fullfile(path2CurrentAnimalID,dirContentCurrentAnimalID(iCOND).name,...
                    dirContentCurrentCond(iDAY).name,dirContentCurrentDAY(iEXP).name );
                fprintf('\n\t\t\t|-->EXP "%s"\t\t(%d/%d)',dirContentCurrentDAY(iEXP).name,iEXP,numEXPinCurrentDAY);
                experimentID = dirContentCurrentDAY(iEXP).name;
                experimentID = experimentID(strfind(experimentID,'_')+1:end);
                % now we look for FOV_
                dirContentCurrentEXP = dir([path2CurrentEXP filesep 'FOV_*']);
                if isempty(dirContentCurrentEXP)
                    warning('No EXP_x directory present - inconsistent tree')
                end
                
                numFOVinCurrentEXP = numel(dirContentCurrentEXP);
                for iFOV = 1 : numFOVinCurrentEXP
                    path2CurrentFOV = fullfile(path2CurrentAnimalID,dirContentCurrentAnimalID(iCOND).name,...
                        dirContentCurrentCond(iDAY).name,dirContentCurrentDAY(iEXP).name,...
                        dirContentCurrentEXP(iFOV).name  );
                    fprintf('\n\t\t\t|-->FOV "%s"\t\t\t(%d/%d)',dirContentCurrentEXP(iFOV).name,iFOV,numFOVinCurrentEXP);
                    
                    FOV = dirContentCurrentEXP(iFOV).name;
                    FOV = FOV(strfind(FOV,'_')+1:end);
                   
                    %finally got to last leaf - GET DATA HERE
                    [ thisRow ] = getDataFromCurrentDir( path2CurrentFOV ,animalID, dataRow);
                    thisRow.animalID = animalID;
                    thisRow.conditionID = conditionID;
                    thisRow.daysAfterBaseline = dirContentCurrentCond(iDAY).name;
                    thisRow.experimentType = experimentID;
                    thisRow.FOV = FOV;
%                     thisRow.run_stim=run_stim;   ag commented 14/12/16
%                     thisRow.run_no_stim=run_no_stim;
%                     thisRow.stand_stim=stand_stim;
%                     thisRow.stand_no_stim=stand_no_stim;
                    %generate summary figure
                    generateBasicSumary(path2sourceDir,thisRow)
                    
                    %append to struct
                    EP_FILES_COMPILED = [EP_FILES_COMPILED; thisRow];
                    
 
                end %cycling FOVs
                                
            end%cycling EXP in current DAY
            
        end% cycling DAY_ hierarchy

    end %cycling conditions (i.e. directoris inside animalID root directory)
    fprintf('\n')
end%cycling animal ids
%%
fprintf('\nSaving data (.mat and .txt) to %s \n',path2sourceDir);
save(fullfile(path2sourceDir,'EP_FILES_COMPILED.mat'),'EP_FILES_COMPILED')
