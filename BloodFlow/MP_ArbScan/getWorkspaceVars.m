function dataVars = getWorkspaceVars(path2RESfile,variables2extract)
%getWorkspaceVars funciton returns specific variables created from
%pathAnalyzeGUI. Variable names are "line_num_AnalysisType_Units". Inputs
%to this functions refer to the "AnalysisType_Units" section of the string
%variable name.

%usage
% dataVars = getWorkspaceVars(path2RESfile,variables2extract)
% where variables2extract is a cell array of strings, usually:
% radon_um_per_s,diameter_um and diameter_um.
% e.g. gatherRESfiles(ptr2RESfile,{'radon_um_per_s','diameter_um','intensity'})
% Alternatively, use 'all' to gather default variables (as in the above
% example). If a variable is specified but not found in workspace, nothing
% is added.

load(path2RESfile)
%%

if ischar(variables2extract)
   if strcmp(variables2extract,'all')
       variables2extract = {'radon_um_per_s','diameter_um','intensity'}
   end
end

%%

nVars2extract = numel(variables2extract);
dataVars=struct('name',[],'varType',[],'y',[],'t',[],'y_mean',[],'y_std',[],'freq',[]);
%the time axis is equal for all lines in each RES so select one and repeat for all
thisDataTypeLines = whos('*_time_axis');
eval(sprintf('t=%s;',thisDataTypeLines(1).name)); %this creates variable t



iDATAVAR = 0;
for iVAR = 1  : nVars2extract
    thisDataTypeLines = whos(['*_' variables2extract{iVAR}]);
    nDataLines= numel(thisDataTypeLines);
    for iLINE = 1:nDataLines
        iDATAVAR = iDATAVAR +1;
        dataVars(iDATAVAR).name = thisDataTypeLines(iLINE).name;
        dataVars(iDATAVAR).t = t;
        dataVars(iDATAVAR).varType = variables2extract{iVAR};
        eval(sprintf('dataVars(%d).y = %s;',iDATAVAR,dataVars(iDATAVAR).name));   
        dataVars(iDATAVAR).y_mean = mean(dataVars(iDATAVAR).y);
        dataVars(iDATAVAR).y_std = std(dataVars(iDATAVAR).y);
%         dataVars(iDATAVAR).freq = freq;
    end  
end

%% check if variable freq_Hz exists in base wo
if exist('freq_Hz','var')

    tmp = num2cell(repmat(freq_Hz,numel(dataVars),1));
else
    tmp = num2cell(nan(numel(dataVars),1));
end
[dataVars.freq] = tmp{:};% 
