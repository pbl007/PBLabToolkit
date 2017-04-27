% RelativePhotonArrivalTime = ArrivalTimeRelativer(SteeringTimes,PhotonTimes)
%
% Relative time between photon arrival time and respective beam steering device trigger pulse
% SteeringTimes is a vector of timings for the beam steering device trigger
% pulses, in 800 ps time bins.
% PhotonTimes is a vector of photon arrival timings, in 800 ps time bins.
% RelativePhotonArrivalTime is a vector of time differences, in 800 ps time bins,
% between a photon arrival time and its respective beam steering device
% pulse
%

function [SteerPeriodicity RelativePhotonArrivalTime] = ArrivalTimeRelativer(SteeringTimes,PhotonTimes)
tic
SteeringTimesArray = table2array(SteeringTimes);
PhotonTimesArray = table2array(PhotonTimes);
disp('\n Array conversion time: \n')
toc
tic
% MaximalSteeringPeriod = max(diff(table2array(SteeringTimes)));

RelativePhotonArrivalTime = zeros(size(PhotonTimesArray));

RunningIndex = 0;

SteerPeriodicity = median(diff(SteeringTimesArray));

if(isnan(SteerPeriodicity))
    disp('0-1 steering sync events found, consider quitting!')
    return;
else
    FirstSteerTime = SteerPeriodicity(1)-SteerPeriodicity; % Guessing time of previous steering event before actual measurement
    LastSteerTime = SteerPeriodicity(end)+SteerPeriodicity; % Guessing time of trailing steering event after actual measurement
    ExtrapolatedSteeringTimes = [FirstSteerTime ; SteeringTimesArray ; LastSteerTime];
    
    for m = 1:numel(ExtrapolatedSteeringTimes)-1
        % if a photon arrived later than the next trigger, it should be attributed to the next cycle:
        RelevantPhotons = PhotonTimesArray( (PhotonTimesArray >= ExtrapolatedSteeringTimes(m)) & (PhotonTimesArray < ExtrapolatedSteeringTimes(m+1)));
        RelativePhotonArrivalTime(RunningIndex+1: RunningIndex + numel(RelevantPhotons)) = RelevantPhotons - ExtrapolatedSteeringTimes(m);
        RunningIndex = RunningIndex + numel(RelevantPhotons);
    end
    
end
% RelativePhotonArrivalTime = RelativePhotonArrivalTime(RelativePhotonArrivalTime>0);
disp('\n Rest of function time: \n')
toc
end


