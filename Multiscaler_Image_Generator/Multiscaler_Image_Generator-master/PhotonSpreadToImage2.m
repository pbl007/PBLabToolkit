function [RawImage, C] = PhotonSpreadToImage2(PhotonCellArray, SizeX, SizeY, Num_of_Lines)
%% Populating the raw image


RawImage = single(zeros(SizeX,SizeY));
C = cell(NumFrames);
% Building a histogram of photon locations
[ RawImage(:,:,m), C{m} ] = hist3([],'Nbins',[SizeX SizeY], 'Edges', );

for m = 1:NumFrames
    if numel(TotalHitsX{m})
        Minumel = min(numel(TotalHitsX{m}), numel(TotalHitsZ{m}));
        
%         for n = 1:numel(TotalHitsX{m})
% %             RawImage(round(LegalHitsX{m}(n)./ShrinkFactorX) +1 ,   round(LegalHitsZ{m}(n)./ShrinkFactorZ)+1, m) = 1 + RawImage(round(LegalHitsX{m}(n)./ShrinkFactorX) +1 ,   round(LegalHitsZ{m}(n)./ShrinkFactorZ)+1, m);
%             RawImage(RescaledX{m}(n), RescaledZ{m}(n), m) = 1 + RawImage(RescaledX{m}(n), RescaledZ{m}(n), m);
 
%         end
    end
end