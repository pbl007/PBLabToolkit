TotalHitsX = cell(1,1e4);
TotalHitsZ = cell(1,1e4);


SweepIndex = 1;

for SweepNumber = 1:100 % Looping over sweeps
    

    photon_single_sweep = STOP1_Dataset((STOP1_Dataset.Sweep_Counter == SweepNumber),1);
    Galvo_single_sweep = STOP2_Dataset((STOP2_Dataset.Sweep_Counter == SweepNumber),1);
    TAG_single_sweep = START_Dataset((START_Dataset.Sweep_Counter == SweepNumber),1);


    % MaximalGalvoPeriod = max(diff(table2array(Galvo_single_sweep)));
    % 
    % [G,P] = meshgrid(single(table2array(Galvo_single_sweep)),single(table2array(photon_single_sweep)));
    % 
    % RawRelativePhotonArrivalTime = P-G;
    % RawRelativePhotonArrivalTime(RawRelativePhotonArrivalTime < 1) = 1e10;
    % RawRelativePhotonArrivalTime(RawRelativePhotonArrivalTime > MaximalGalvoPeriod) = 1e10;
    % 
    % RelativePhotonArrivalTime = min(RawRelativePhotonArrivalTime');
    % RelativePhotonArrivalTime(RelativePhotonArrivalTime>1e9) = 1;

    PhotonArrivalTimesRelativeToGalvo = ArrivalTimeRelativer(Galvo_single_sweep,photon_single_sweep);
    PhotonArrivalTimesRelativeToUltraFastLens = ArrivalTimeRelativer(TAG_single_sweep,photon_single_sweep);

    TotalHitsX{SweepIndex} = PhotonArrivalTimesRelativeToGalvo;
    TotalHitsZ{SweepIndex} = PhotonArrivalTimesRelativeToUltraFastLens;
    
    SweepIndex = SweepIndex + 1;

end

NumFrames = SweepIndex-1;

