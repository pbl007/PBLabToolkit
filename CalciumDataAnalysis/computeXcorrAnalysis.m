function thisEXP = computeXcorrAnalysis(thisEXP,prmts)

% prmts.doComputeSHIFT = 0;
% prmts.doComputeSVD = 0;
% prmts.doSubsampleImg = 1;
% prmts.minCorrValToPlotEdges = 0.6;

%
if prmts.doSubsampleImg
    img = thisEXP.maxProjImg;
    imgSize = size(img);
    img = imresize(img(1:2:end,:),imgSize/2);
end

%% get data 
%this is the C_df matrix of the EP analysis
S_or = thisEXP.S_or;
Coor = thisEXP.Coor;
dF = thisEXP.C_df;
[nCells nT] = size(dF);
%% plot traces

%add an increment to each dF line so they separate in the plot
figure

subplot(3,2,3)
offset = [1:nCells]';
offset = repmat(offset,1,nT);
plot(1:nT,dF+offset)
set(gca,'xcolor',[1 1 1].*0.5,'ycolor',[1 1 1].*0.5)
grid on
box off
title('\DeltaF/F_{0}')
ylabel('Cell ID')
set(gca,'xticklabel',{})
subplot(3,4,9)
imagesc(log(S_or))
colormap summer
linkaxes(findobj(gcf,'type','axes'))
set(gca,'xcolor',[1 1 1].*0.5,'ycolor',[1 1 1].*0.5,'ydir','normal')
grid on
box off
title('Log ( S_{or} )')
ylabel('Cell ID')
xlabel('Frame')


%% filtering
% Low pass Butterworth filter - not sure we need this as we have the
%estimaged traces after deconvolution of spike event (EP code or similar).

%% cross correlate
% compute cross correlation, normalized by the autocorrelation at zero lag
%using the following (A x B)/[norm(A) * norm(B)] where A and B are the
%"deconvolved" calcium vectors and "norm" outputs the Euclidean lenght of
%each vector, Pearson correlation gives an identical answer...
[R,PR]=corrcoef(dF','rows','pairwise');

%% plot an ordered correlation matrix based on distances on the the
%correlation space
D = pdist(R);
tree = linkage(D,'average');
leafOrder = optimalleaforder(tree,D);

figure
subplot(1,2,1)
imagesc(R)
axis square
axis off
colorbar

subplot(1,2,2)
imagesc(R(leafOrder,leafOrder))
axis square
axis off

map  = colormap(summer);
map(end,:)=[0.5 0.5 0.5];%gray out main diagonal
colormap(map)

colorbar


%% compute correlation as funciton of distance
kpairs = nchoosek(1:nCells,2);
nPairs = size(kpairs,1);

%build adjacency matrix based on correlation coefficient (start by using
%only significant correlation p<0.5)

Adj = R.*(PR<0.001);
AdjPos = Adj;
AdjNeg = Adj;
AdjPos(Adj<prmts.minCorrValToPlotEdges)=0;
AdjNeg(Adj>-prmts.minCorrValToPlotEdges)=0;
% figure;
clf
imagesc(img)
colormap(copper)
hold on
myctr = zeros(size(Adj,1),2);
for iCOOR = 1 : numel(Coor)
    xi = Coor{iCOOR,1}(1,:);
    yi = Coor{iCOOR,1}(2,:);
    myctr (iCOOR,:) = [mean(xi) mean(yi)];
    plot(xi,yi,'r.')
    text(myctr(iCOOR,1),myctr(iCOOR,2),num2str(iCOOR))
end
% % % % % for iCOOR = 1 : size(A_or,2)
% % % % % 
% % % % % 
% % % % %     BW = zeros(245,245);
% % % % %     idx = find(A_or(:,iCOOR));
% % % % %     BW(idx)=1;
% % % % %     idxPerim = regionprops(BW,'PixelIdxList' )
% % % % % 
% % % % %     plot(xi,yi,'r.')
% % % % %     text(myctr(iCOOR,1),myctr(iCOOR,2),num2str(iCOOR))
% % % % % end

[hE,hV]=wgPlot(AdjPos,myctr,'edgecolormap',summer(64),'vertexmarker','o');
%[hE,hV]=wgPlot(AdjNeg,myctr,'edgecolormap',spring(64),'vertexmarker','o');
axis image

%% plot correlation as a function of distance
D = squareform(pdist(myctr));
kPairsIdx = sub2ind(size(D),kpairs(:,1),kpairs(:,2));
kPairsDist = D(kPairsIdx);
kPairsCorrcoef = R(kPairsIdx);

% figure
set(gca,'linewidth',2,'FontSize',24)
clf
posCorrIdx = kPairsCorrcoef>0;
negCorrIdx = kPairsCorrcoef<0;
x = kPairsDist(posCorrIdx);
y = kPairsCorrcoef(posCorrIdx);
hold on
plot(x,y,'ro','markerfacecolor',[0.9 0.6 0.6 ],'markersize',12)
brobPos = robustfit(x,y);
plot(x,brobPos(1)+brobPos(2)*x,'r-','linewidth',3)

x = kPairsDist(negCorrIdx);
y = kPairsCorrcoef(negCorrIdx);
plot(x,y,'ko','markerfacecolor',[0.6 0.6 0.6],'markersize',12)
brobNeg = robustfit(x,y);
plot(x,brobNeg(1)+brobNeg(2)*x,'k-','linewidth',3)
xlabel('Distance','FontSize',22)
ylabel('Correlation Coeff','FontSize',22)
%% compute significance
% compute significance by "shifting" 100 times the traces and recomputing
%this used the SHIFT algorithm of Louie and Wilson 2001:
%
% Entire spike train vectors are temporally shifted relative to original alignment,
% with relative temporal order preserved within each spike train. The shift distance
% is pseudorandomly chosen and ranges between half the window length backward and
% half the window length forward. The shift is circular, such that data removed from
% the pattern at one end is reinserted at the opposite end.

if prmts.doComputeSHIFT
    kpairs = nchoosek(1:nCells,2);
    nPairs = size(kpairs,1);
    nSim = 1000;
    Psim = zeros(nPairs,1);
    parfor iPair = 1 : nPairs
        for iITER = 1 : nSim
            v1 = circshift(dF(kpairs(iPair,1),:),[1 -randi(nT/2)]);%shift backwards
            v2 = circshift(dF(kpairs(iPair,2),:),[1 randi(nT/2)]);%shift forward
            rsim = corrcoef(v1,v2);
            Psim(iPair) = Psim(iPair) + double(rsim(2)<R(kpairs(iPair,1),kpairs(iPair,1)));
        end %iter
    end %pairs
    Psim = Psim/nSim;
end
%% SVD analysis on matrix  (plot eigenval of 10 first eigvectors)

if prmts.doComputeSVD
    [U,S,V] = eig(R);
    figure
    plot(diag(S))
    xlabel('Eigenvector')
    ylabel('Eigenvalue')
end



%% append new fields 
thisEXP.D = D;