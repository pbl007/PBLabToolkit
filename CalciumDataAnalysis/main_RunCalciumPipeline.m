%% CALCIUM ANALYSIS PIPELINE

%% Step one: Create a .mat file for EP's algorithm to read
files = uipickfiles('Prompt', 'Please select folders and files for the analysis pipeline',...
                    'FilterSpec', '*.tif', 'Output', 'struct');
run('/data/MatlabCode/PBLabToolkit/CalciumDataAnalysis/FromAG/AG_SparateChannels.m')


%% Step two: Run EP's algorithm. This includes the manual refinement of components

% Parameters:
FOV = [512, 512];
numFiles = length(files);

delete([foldername, '/*_rig.mat']);
delete([foldername, '/*_rig.h5']);
delete([foldername, '/*_nr.h5']);

run('/data/MatlabCode/PBLabToolkit/External/ca_source_extraction/run_pipeline.m')

%% 