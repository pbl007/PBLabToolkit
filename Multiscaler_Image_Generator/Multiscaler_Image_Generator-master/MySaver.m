OutputFileName = strcat('MultiscalerMovie-', FileName(1:end-3),'mat' );
clear PMT_Dataset Binary_Data; % To avoid the -v7.3 switch
save(OutputFileName);

% plot(TotalHitsX,TotalHitsZ,'.')