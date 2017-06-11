%% CALCIUM ANALYSIS PIPELINE
clearvars;
close all;

%% Step one: Create a .mat file for EP's algorithm to read
addpath('/data/MatlabCode/PBLabToolkit/CalciumDataAnalysis/');
addpath(genpath('/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction'));
foldername = uigetdir('/data/David/new_exp_calcium_TAC/', ...
                      'Define a parent folder for all data. This will be the results directory.');
files = uipickfiles('Prompt', 'Please select folders and files for the analysis pipeline',...
                    'FilterSpec', [foldername, filesep, '*.tif'], 'Output', 'struct');

fprintf('Separating channels from Tiffs and loading into memory... ');
cd('/data/MatlabCode/PBLabToolkit/CalciumDataAnalysis');
numOfChannels = 2;  % two data channels
AG_SparateChannels;

%% Script Parameters
FOV = [header.xPixels, header.yPixels];
numFiles = length(files);

%% Step two: Run EP's algorithm. This includes the manual refinement of components
% Run validations on data
run('/data/MatlabCode/PBLabToolkit/CalciumDataAnalysis/inputValidations.m');

% Run EP's pipeline
fprintf("Done. \nStarting EP's pipeline.\n");
run('/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction/run_pipeline.m');

if isTACFile
    %% Step three: Create EP_FILES_COMPILED
    % Save the .mat file
    fprintf('Saving files...\n')
    createFolderStructure;
    saveMatInFolderStructureWithoutCompiled;

    % Create the structured array
    EP_FILES_COMPILED = AG_gatherCalciumMatFiles([foldername, filesep, ...
                                                  'results', filesep]);

    %% Step four: Run the analysis scripts
    fprintf('Processing analog data... ');
    EP_FILES_COMPILED = AG_slice_EP_variables(EP_FILES_COMPILED, header);
    fprintf('Done.\n');
    
    %% Step five: Dissect the data for "spike sorting" 
    % EP_FILES_COMPILED = AG_SummarizeDay(EP_FILES_COMPILED);

    %% Finally - save the file
    saveMatInFolderStructureWithCompiled;
end


