function generateBasicSumary (path2sourceDir,thisRow)

%% C_df matrix of the EP analysis

dF = thisRow.C_df;
[nCells nT] = size(dF);
img = thisRow.maxProjImg;
Coor = thisRow.Coor;
S_or = thisRow.S_or;

%% plot image
figure('Name',thisRow.dataFileName)
subplot(3,3,[2 3 5 6])
imagesc(img)
axis image
title(thisRow.dataFileName)
imagesc(img)
colormap copper
hold on
myctr = zeros(size(Coor,1),2);
for iCOOR = 1 : numel(Coor)
    xi = Coor{iCOOR,1}(1,:);
    yi = Coor{iCOOR,1}(2,:);
    myctr (iCOOR,:) = [mean(xi) mean(yi)];
    plot(xi,yi,'r.','markerSize',8)
    text(myctr(iCOOR,1),myctr(iCOOR,2),num2str(iCOOR))
end
axis image
axis off

%% plot traces

%add an increment to each dF line so they separate in the plot


a1 = subplot(3,3,[1 4]);
offset = [1:nCells]';
offset = repmat(offset,1,nT);
plot(1:nT,dF+offset,'LineWidth',2)
set(gca,'xcolor',[1 1 1].*0.5,'ycolor',[1 1 1].*0.5)
grid on
box off
title('\DeltaF/F_{0}')
ylabel('Cell ID')
set(gca,'xticklabel',{})
a2 = subplot(3,3,7);
imagesc(log(S_or))
%colormap summer
linkaxes([a1 a2])
set(gca,'xcolor',[1 1 1].*0.5,'ycolor',[1 1 1].*0.5,'ydir','normal')
grid on
box off
title('Log ( S_{or} )')
ylabel('Cell ID')
xlabel('Frame')

%%
filename = thisRow.dataFileName(1:strfind(thisRow.dataFileName,'.mat')-1)

export_fig(fullfile(path2sourceDir,filename))