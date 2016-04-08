figure;
subplot(2,2,1)
imshow(RawImage',[]); axis square;colorbar;
subplot(2,2,2)
imshow(log(double(RawImage'+1)));colorbar; axis square;
SmallImage = RawImage(:,round(size(RawImage,2).*0.8):end); 
subplot(2,2,3)
imshow(SmallImage',[]);;axis square;colorbar;
subplot(2,2,4)
imshow(log(double(SmallImage'+1)),[]);;axis square;colorbar;