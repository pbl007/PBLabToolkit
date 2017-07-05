
%% CALCIUM ANALYSIS PIPELINE
clearvars;
close all;

%% Step one: Create a .mat file for EP's algorithm to read
addpath('/data/MatlabCode/PBLabToolkit/External/NoRMCorre/');
if size(lastwarn, 2) > 0 
    prefix = '/state/partition1/home/pblab';
    addpath([prefix '/data/MatlabCode/PBLabToolkit/External/NoRMCorre/']);
else
    prefix = '';
end

foldername = uigetdir([prefix '/data/David/THY_1_GCaMP_BEFOREAFTER_TAC_290517/'], ...
                     'Define a parent folder for all data. This will be the results directory.');

files = uipickfiles('Prompt', 'Please select folders and files for the analysis pipeline',...
                    'FilterSpec', [foldername, filesep, '*.tif'], 'Output', 'struct');

fprintf('Separating channels from Tiffs and loading into memory... ');

cd([prefix '/data/MatlabCode/PBLabToolkit/CalciumDataAnalysis']);
numOfChannels = 2;  % number of data channels
AG_SparateChannels;

%% Script Parameters
FOV = [header.xPixels, header.yPixels];
numFiles = length(files);

%% Step two: Run EP's algorithm. This includes the manual refinement of components
% Run validations on data
run([prefix '/data/MatlabCode/PBLabToolkit/CalciumDataAnalysis/inputValidations.m']);

% Run EP's pipeline
fprintf("Done. \nStarting EP's pipeline.\n");
run([prefix '/data/MatlabCode/PBLabToolkit/External/EP_ca_source_extraction/ca_source_extraction/run_pipeline.m']);

if isTACFile
    %% Step three: Create EP_FILES_COMPILED
    % Save the .mat file
    fprintf('Saving files...\n')
    createFolderStructure;
    saveMatInFolderStructureWithoutCompiled;
    % Create the structured array
    EP_FILES_COMPILED = loadData(files, filepaths, header);
    
    %% Step four: Run the analysis scripts
    fprintf('Processing analog data... ');
    EP_FILES_COMPILED = AG_slice_EP_variables(EP_FILES_COMPILED, header);
    fprintf('Done.\n');
    
    %% Step five: Dissect the data for "spike sorting" 
    % EP_FILES_COMPILED = AG_SummarizeDay(EP_FILES_COMPILED);

    %% Finally - save the file
    saveMatInFolderStructureWithCompiled;
end


