TotalHitsX = [];
TotalHitsZ = [];



for SweepNumber = 1:3 % Looping over sweeps

    photon_single_sweep = PMT_Dataset((PMT_Dataset.Sweep_Counter == SweepNumber),1);
    Galvo_single_sweep = Galvo_Dataset((Galvo_Dataset.Sweep_Counter == SweepNumber),1);
    TAG_single_sweep = TAG_Dataset((TAG_Dataset.Sweep_Counter == SweepNumber),1);


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

    TotalHitsX = [TotalHitsX; PhotonArrivalTimesRelativeToGalvo];
    TotalHitsZ = [TotalHitsZ; PhotonArrivalTimesRelativeToUltraFastLens];

end



