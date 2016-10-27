SumImage = sum(RawImagesMat,3);
ProdImage = prod(RawImagesMat+1,3) - 1;
ProdImage2 = prod(RawImagesMat+0.5,3) - prod(0.5.*ones(size(RawImagesMat)),3);

RawImage2(:,:,1) = SumImage;
RawImage2(:,:,2) = ProdImage ;
RawImage2(:,:,3) = ProdImage2;

figure;
subplot(2,2,1)
imshow(RawImage2,[]); axis square;colorbar;
subplot(2,2,2)
imshow(log(double(RawImage2+1)),[]);colorbar; axis square;
SmallImage = RawImage2(:,round(size(RawImage2,2).*0.8):end,1); 
subplot(2,2,3)
imshow(SmallImage,[]);axis square;colorbar;
subplot(2,2,4)
imshow(log(double(SmallImage+1)),[]);;axis square;colorbar;

% figure;imshow(log(RawImage+1),[]); axis square;colorbar;
