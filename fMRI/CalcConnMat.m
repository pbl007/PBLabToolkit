function CM=CalcConnMat(fileName,TR,lowCutOff,highCutOff)
% ----------------------------------------------------------------------- %
% function CM=CalcConnMat(fileName,TR)
% I. Tavor - Jan 2019
% Calculate an ROI-based connectivity matrix from resting-state fMRI.
% <fileName> is the the name (and path) of a 4D minimally preprocessed
% NIfTI image. This function assumes that the image is already skull
% stripped, motion corrected and spatially aligned to a mouse Atlas.
%
%<TR> is the scan repetition time in seconds
% ----------------------------------------------------------------------- %

if nargin<4
    lowCutOff  = 0.01;
    highCutOff = 0.1;
end

% load the ROI atlas and the RS-fMRI data
disp('Load data')

load('label2subject.mat')
data=niftiread(fileName);

% calculate the mean time series for each region
disp('Calculate mean time series');
numPoints=size(data,4);
numRegions=max(label2subject(:));

vecData=reshape(data,[],numPoints);
atlas=label2subject(:);

allTs=zeros(numRegions,numPoints);
for i=1:numRegions
    allTs(i,:)=mean(vecData(atlas==i,:));
end

disp('Run bandpass filtering')
% save mean signal (removed before lowpass filtering and then added back
meanSig=mean(allTs,2); 
meanSig=repmat(meanSig,1,numPoints);
% Perform bandpass filtering 

TS_hp=highpass(allTs',lowCutOff,1/TR)';
TS_bp=lowpass(TS_hp',highCutOff,1/TR)'+meanSig;

save TEMP allTs TS_hp TS_bp meanSig

% calculate correlations

disp('Calculate Correlations');

CM = corr(TS_bp');

end

