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

function RelativePhotonArrivalTime = ArrivalTimeRelativer(SteeringTimes,PhotonTimes)

SteeringTimesArray = table2array(SteeringTimes);
PhotonTimesArray = table2array(PhotonTimes);

% MaximalSteeringPeriod = max(diff(table2array(SteeringTimes)));

RelativePhotonArrivalTime = zeros(size(PhotonTimesArray));

RunningIndex = 0;

for m = 1:numel(SteeringTimesArray)-1
    % if a photon arrived later than the next trigger, it should be attributed to the next cycle:
    RelevantPhotons = PhotonTimesArray( (PhotonTimesArray >= SteeringTimesArray(m)) & (PhotonTimesArray < SteeringTimesArray(m+1)));
    RelativePhotonArrivalTime(RunningIndex+1: RunningIndex + numel(RelevantPhotons)) = RelevantPhotons - SteeringTimesArray(m);
    RunningIndex = RunningIndex + numel(RelevantPhotons);
end
