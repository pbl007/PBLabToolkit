function dataVars = getWorkspaceVars(path2RESfile,variables2extract)
%getWorkspaceVars funciton returns

load(path2RESfile)
%%

nVars2extract = numel(variables2extract);
dataVars=struct('name',[],'varType',[],'y',[],'t',[],'y_mean',[],'y_std',[],'freq',[]);
%the time axis is equal for all lines in each RES so select one and repeat for all
thisDataTypeLines = whos('*_time_axis');
eval(sprintf('t=%s;',thisDataTypeLines(1).name)); %this creates variable t

%check if variable freq_Hz exists in base wo
if exist('freq_Hz','var')
%     cmd = 'gotFreq = exist(''freq_Hz'',''var'')';
%     evalin('base',cmd)
    dataVars.freq = freq_Hz;
else
    dataVars.freq = -1;
end

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



