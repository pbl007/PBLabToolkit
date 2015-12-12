%script to analyze data for TAC experiments
clc
path2groupledResults = '/Users/pb/Data/PBLab/David/TAC/RES_files';
groupedResultsBaseFileName = 'RES_TAC';
%append time stamp
groupedResultsFileName = [groupedResultsBaseFileName  datestr(now,'_YYYYmmdd_HHMMSS')];



path2sourceDir = '/Users/pb/Data/PBLab/David/TAC/RES_files';
variables2extract = {'diameter_um';'radon_um_per_s'};
%collect results
T = gatherRESfiles(path2sourceDir,path2groupledResults,groupedResultsFileName,variables2extract);
