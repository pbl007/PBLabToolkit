%This scrips sequentially loads and runs multiple 'a' files (created with
%the "analyze later option" selected in the pathAnalyzeGUI.

%select folder containing the a files, they can be all moved to a single
%folder as long as the original data is not moved.

path2aFilesDir = uigetdir;

listOfStoredFiles = dir([path2aFilesDir filesep 'a*.m'])
nFiles = numel(listOfStoredFiles);
if nFiles<1
    error('This folder has no ''a'' files stored... sorry, can''t make this work for you... I have no mental abilities to guess what you want')
    return
end

%% if we got here we gotta do something wiht those damm a files....
%
for iFILE = 1 : nFiles
   %run each file so we create the dataStructure
   
   clear dataStruct dataStructArray
   %generate command to current a file, this generates a new dataStructure
   %array.
   mycommand = sprintf('run(''%s'')',fullfile(path2aFilesDir,listOfStoredFiles(iFILE).name));
   eval(mycommand)
   
   %run analysis on current dataStr
   pathAnalysisHelper(dataStructArray)
end