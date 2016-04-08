figure;
subplot(2,2,1)
imshow(RawImage',[]); axis square;
subplot(2,2,2)
imshow(log(double(RawImage'+1)));colorbar; axis square;
SmallImage = RawImage(:,8000:end); 
subplot(2,2,3)
imshow(SmallImage',[]);colorbar;axis square;
subplot(2,2,4)
imshow(log(double(SmallImage'+1)),[]);colorbar;axis square;