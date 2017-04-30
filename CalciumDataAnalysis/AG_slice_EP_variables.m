%this script splices S-Or and C_df according running/no running and
%stimulus present/unpresent (time window of 500msec 
%% initialization
function compiled = AG_slice_EP_variables(compiled, imgHeader)

responseWindow = 0.5;  % seconds
stimTotalTime = 0.5;  % seconds
puffInterval = 15;  % seconds
moveThresh = 0.25;  % Volts 
sampleRate = 1000;  % Hz
samplesPerFrame = ceil(sampleRate / compiled.fps);
        
%% going over the rows and computing which frames belong to which condition
% run_no_stim, run_stim, stand_no_stim, stand_stim

for iEX=1:numel(compiled)    
    if (~isempty(compiled(iEX).stimVector)) && (~isempty(compiled(iEX).S_or))
        %% Separate the two types of stimuli
        stimVec = zeros(size(compiled(iEX).stimVector));      
        juxtaVec = zeros(size(compiled(iEX).stimVector));
        
        %% Find the peaks of the stimulations and fakes
        [~ ,locsStim] = findpeaks(compiled(iEX).stimVector, ...
                                  'MinPeakHeight', 4, ...
                                  'MinPeakDistance', sampleRate * 2);
        [~ ,locsJuxta] = findpeaks(compiled(iEX).stimVector, ...
                                  'MinPeakHeight', 2, ...
                                  'MinPeakDistance', sampleRate * 2);
        locsJuxta = setdiff(locsJuxta, locsStim);
        
        %% Add 1's to the "response window" following a stimulus
        for idx = locsStim'
           stimVec(idx:idx + (responseWindow + stimTotalTime) * sampleRate) = 1; 
        end
         
        for idx = locsJuxta'
           juxtaVec(idx:idx + (responseWindow + stimTotalTime) * sampleRate) = 1; 
        end
        
        %% Find the frames in which a stimuli occurred (the actual loop comes later)
        frameStartTimes = floor(imgHeader(iEX).frameTimestamps_sec(1:2:end) * sampleRate);  % Assuming two data channels only
        frameStartTimes(1) = 1;  % 1-based indexing
        stimFrames = zeros(size(frameStartTimes));
        juxtaFrames = zeros(size(frameStartTimes));
        
        %% Find the running frames
        runVec = zeros(size(compiled(iEX).speedVector));         
        if size(runVec, 1) ~= size(stimVec, 1)
            error('Mismatch between the two analog files in ex %d \n', iEX);
        end
        
        % Iterate over all frames and see if the mouse usually ran there
        runVec(compiled(iEX).speedVector > moveThresh) = 1;
        runFrames = zeros(size(frameStartTimes));
        
        %% Loop over data finding fake, stim and running frames
        idx = 1;
        
        for frameTime = frameStartTimes
           curMeanStim = mean(stimVec(frameTime:frameTime + samplesPerFrame));
           curMeanJuxta = mean(juxtaVec(frameTime:frameTime + samplesPerFrame));
           curMeanRun = mean(runVec(frameTime:frameTime + samplesPerFrame));
           
           if curMeanStim > 0.5
              stimFrames(idx) = 1;
           end
           
           if curMeanJuxta > 0.5
               juxtaFrames(idx) = 1;
           end
           
           if curMeanRun > 0.5
               runFrames(idx) = 1;
           end
           idx = idx + 1;
        end        

        %% Separate S_or and C_df into the 6 matrices
        S_or=compiled(iEX).S_or;
        compiled(iEX).S_or_run_stim = S_or(:, stimFrames & runFrames);
        compiled(iEX).S_or_run_spont = S_or(:, ~stimFrames & ~juxtaFrames & runFrames);
        compiled(iEX).S_or_run_juxta = S_or(:, juxtaFrames & runFrames); 
        compiled(iEX).S_or_stand_stim = S_or(:, stimFrames & ~runFrames); 
        compiled(iEX).S_or_stand_spont = S_or(:, ~stimFrames & ~juxtaFrames & ~runFrames);  
        compiled(iEX).S_or_stand_juxta = S_or(:, juxtaFrames & ~runFrames);
        
        C_df=compiled(iEX).C_df;
        compiled(iEX).C_df_run_stim = C_df(:, stimFrames & runFrames);
        compiled(iEX).C_df_run_spont = C_df(:, ~stimFrames & ~juxtaFrames & runFrames);
        compiled(iEX).C_df_run_juxta = C_df(:, juxtaFrames & runFrames); 
        compiled(iEX).C_df_stand_stim = C_df(:, stimFrames & ~runFrames); 
        compiled(iEX).C_df_stand_spont = C_df(:, ~stimFrames & ~juxtaFrames & ~runFrames);  
        compiled(iEX).C_df_stand_juxta = C_df(:, juxtaFrames & ~runFrames);
        
    end
end 
end