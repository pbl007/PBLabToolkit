%% Script info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: "Plot_TAG_Phase.m"                                %
% Purpose: When the user desires it take data from PMT and TAG %
% lens and find the phase of each data point in the TAG        %
% period. Note that it adds another column to existing data    %
% table containing phase data, between 0 and 2pi.              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [InterpData] = Plot_TAG_Phase(DataAsTable, frequency, TAGData)

%% First we make sure that the TAG data is regular and there are no missing lines
% Define frequency and noise levels
TAGData = table2array(TAGData(:,1)); % taking only the data itself
baseTimeSeparation = ceil((1/(frequency * 1e3)) ./ 0.8* 10^9); % desired separation between time bins (in units of bins)
allowedNoise = ceil(0.05 * baseTimeSeparation); % allowing 5% jitter in the TAG pulse signal

% Check data vector for errors and correct them, start from the 2nd reading
changedTicks = 1;
while changedTicks ~= 0
    diffVec = diff(TAGData(2:end));
    diffVec = diffVec - baseTimeSeparation;
    diffVec(abs(diffVec) <= allowedNoise) = 0; % if allowed noise is greater than the difference, we zero the cell
    missingTicks = find(diffVec) + 1; % finding all non-zero values. We wrote +1 because of the first cell that was neglected
    
    % Check input vector
    if size(missingTicks, 1) > 0.2 * size(diffVec, 1)
        InterpData = NaN;
        InterpData = table(InterpData);
        return;
    end
    
    if isempty(missingTicks)
        changedTicks = 0;
    else
        changedTicks = size(missingTicks, 1);

        newTicks = TAGData(missingTicks) + baseTimeSeparation; % contains the time stamp of the missing TAG ticks
        TAGData = [TAGData ; newTicks]; % concatenate both arrays, placing new values in the end (simple and straight-forward, we sort them later)

        missingTicks = [];
        newTicks = [];
    end
end

TAGData = sort(TAGData);

%% Now we use the corrected TAG data vector and interpolate a sinusoidal wave across the entire range
Data = table2array(DataAsTable(:, 1));
finalPhaseVec = NaN(size(Data));
startTime = TAGData(2, 1);
endTime = TAGData(3, 1);
deltaTime = endTime - startTime;

% Now we'll find the first relevant event (only after the first TAG pulse)
indexInData = find(Data(:,1) >= TAGData(2,1), 1);
currentData = Data(indexInData:indexInData + 10000, 1); % assuming no more than 10,000 photons will arrive in every TAG period. Don't change the 10k number light-headedly

% CURRENTLY ASSUMING THE TAG PULSE IS AT 0 PHASE!!!
for indexInTAG = 3:(size(TAGData, 1) - 1)
    currentData(:, 1) = currentData(:, 1) - startTime;
    dataToBeSent = currentData(currentData(:, 1) <= deltaTime, 1);
    [phaseVec, sizeOfPhaseVec] = FindThePhase(deltaTime, dataToBeSent);
    
    % Concatenate the new and final vectors
    if ~isempty(phaseVec)
        finalPhaseVec(indexInData:indexInData + sizeOfPhaseVec - 1, 1) = phaseVec;
    end
        
    % Start preparing the next loop
    startTime = endTime;
    endTime = TAGData(indexInTAG + 1, 1);
    deltaTime = endTime - startTime;
    indexInData = indexInData + sizeOfPhaseVec;
    
    % Create the next data vector
    if indexInData < (size(Data, 1) - 15000)
        currentData = [];
        currentData(:, 1) = Data((indexInData):(indexInData + 10000), 1);
    elseif indexInData + sizeOfPhaseVec < size(Data, 1)
        currentData = [];
        currentData(:, 1) = Data((indexInData):end, 1);
    else
        break;
    end  
end

%% Assign vector
InterpData = [DataAsTable, array2table(finalPhaseVec)];
end