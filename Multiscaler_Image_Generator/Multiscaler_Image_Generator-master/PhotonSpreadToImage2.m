function [RawImage, C] = PhotonSpreadToImage2(PhotonCellArray, SizeX, SizeY, Num_of_Lines)
%% Populating the raw image


RawImage = single(zeros(SizeX,SizeY,max(NumFrames,1)));
C = cell(NumFrames);
% Building a histogram of photon locations

for m = 1:NumFrames
    if numel(TotalHitsX{m})
        Minumel = min(numel(TotalHitsX{m}), numel(TotalHitsZ{m}));
        [ RawImage(:,:,m), C{m} ] = hist3([TotalHitsX{m}(1:Minumel)  TotalHitsZ{m}(1:Minumel)],'Nbins',[SizeX SizeY]);
%         for n = 1:numel(TotalHitsX{m})
% %             RawImage(round(LegalHitsX{m}(n)./ShrinkFactorX) +1 ,   round(LegalHitsZ{m}(n)./ShrinkFactorZ)+1, m) = 1 + RawImage(round(LegalHitsX{m}(n)./ShrinkFactorX) +1 ,   round(LegalHitsZ{m}(n)./ShrinkFactorZ)+1, m);
%             RawImage(RescaledX{m}(n), RescaledZ{m}(n), m) = 1 + RawImage(RescaledX{m}(n), RescaledZ{m}(n), m);
 
%         end
    end
end