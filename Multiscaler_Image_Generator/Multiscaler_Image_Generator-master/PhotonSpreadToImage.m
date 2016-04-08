

MaxX = round( max(TotalHitsX(:)) ./ 1e3);
MaxZ = max(TotalHitsZ(:));

% RawImage = uint8(zeros(2*MaxX+5,2*MaxZ+5));
RawImage = (zeros(2*MaxX+5,2*MaxZ+5));


% PhotonPatch = uint8( [1 2 1 ; 2 4 2 ; 1 2 1]);
PhotonPatch = ( [1 2 1 ; 2 4 2 ; 1 2 1]);


for m = 1:numel(TotalHitsX)
    RawImage(2*ceil(TotalHitsX(m)./1e3)+1   :   2*ceil(TotalHitsX(m)./1e3)+3  ,   2*TotalHitsZ(m)+1   :   2*TotalHitsZ(m)+3 ) = RawImage(2*ceil(TotalHitsX(m)./1e3)+1   :   2*ceil(TotalHitsX(m)./1e3)+3,    2*TotalHitsZ(m)+1   :   2*TotalHitsZ(m)+3) + PhotonPatch;
end