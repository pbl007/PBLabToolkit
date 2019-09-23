%% first step
%registering a wide field image onto the allen atlas
load('green_ds.mat')
load('wf areas_scaled.mat')
% here you need to manually choose 11 points of registration. After
% choosing press file and then export to workspace
cpselect(green_ds/70000, A_scaled*70000)%the first is modified to match the second
save reg_points_ALLEN movingPoints fixedPoints

%% second step
%performing the registration. you can also change the function itself. the
%tform is the transformation you can use for any image with the same
%position.
tform = fitgeotrans(movingPoints,fixedPoints,'polynomial',3);
%tform = cp2tform(movingPoints(:,:),fixedPoints(:,:), 'nonreflective similarity');
Jregistered = imwarp(green_ds,tform,'OutputView',imref2d(size(A_scaled))); %aligned map
figure;
imshowpair(imrotate(Jregistered,-90),imrotate(A_scaled,-90));

save registration_to_ALLEN_ATLAS tform
%% third step
%manually chossing areas of interest. change the roi name and open figure
%100. Then click around the area you want and right click once to finish.
%The roi will have the pixel indeces of your defined roi
figure(100);imagesc(Jregistered);
hold on
contour(A_scaled,'k')
roi_XX = choose_polygon_imagesc(256);
