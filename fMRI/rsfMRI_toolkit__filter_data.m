function []= rsfMRI_toolkit__filter_data(data,TR,lowCutOff,highCutOff)



disp('Run bandpass filtering')
% save mean signal (removed before lowpass filtering and then added back
meanSig=mean(allTs,2); 
meanSig=repmat(meanSig,1,numPoints);
% Perform bandpass filtering 

TS_hp=highpass(allTs',lowCutOff,1/TR)';
TS_bp=lowpass(TS_hp',highCutOff,1/TR)'+meanSig;
    

