function [ RES_FILES_COMPILED ] = recomputeStatsForSelectedRegionsInTable( RES_FILES_COMPILED )
%RECOMPUTESTATSFORSELECTEDREGIONSINTABLE Summary of this function goes here
%   This function computes the mean and std for the all traces in the table
%   taking into account the selected regions.
%
%   Pablo - 19/Jul/2016



for iROW = 1 : size(RES_FILES_COMPILED,1)
    t_selected = RES_FILES_COMPILED{iROW,'t_selected'}{:};
    t_selected = reshape(t_selected(:),1,numel(t_selected)); % ensure row vector
    RES_FILES_COMPILED = computeNewStats(RES_FILES_COMPILED,iROW,t_selected);
end



function RES_FILES_COMPILED = computeNewStats(RES_FILES_COMPILED,rowIds,t_selected)
%update corresponding rows

%collapse all selection into single vector
t_selected = sum(t_selected,1);
%plot(t_selected);pause;close(gcf); %used this line for testing
%selection.
for iROW = 1 : numel(rowIds);
    RES_FILES_COMPILED.t_selected{rowIds(iROW)} = t_selected;
    
    %support for single input in RES
    if iscell(RES_FILES_COMPILED.y)
        y_selected_mean = mean(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
        y_selected_std = std(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    else
        tmp = RES_FILES_COMPILED{rowIds(iROW),'y'};
        y_selected_mean = mean(tmp(t_selected>0));
        y_selected_std = std(tmp(t_selected>0));
    end
    RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)) = y_selected_mean;
    RES_FILES_COMPILED.y_selected_std(rowIds(iROW)) = y_selected_std;
    %
    %     RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)) = mean(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    %     RES_FILES_COMPILED.y_selected_std(rowIds(iROW)) = std(RES_FILES_COMPILED.y{rowIds(iROW)}(t_selected>0));
    
    fprintf('\n Original values for row %d where %3.4f±%3.4f, now  %3.4f±%3.4f',rowIds(iROW),...
        RES_FILES_COMPILED.y_mean(rowIds(iROW)),RES_FILES_COMPILED.y_std(rowIds(iROW)),...
        RES_FILES_COMPILED.y_selected_mean(rowIds(iROW)),RES_FILES_COMPILED.y_selected_std(rowIds(iROW)));
    
    
end
