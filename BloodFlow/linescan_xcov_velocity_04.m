function [mv_mpP]=linescan_xcov_velocity_04(mv_mpP)
%this function uses the cross correlation method to measure velocity
%using the method of Kim et al, PLoS ONE 2012
%Patrick Drew 7/2012
%
[~,xc_image,xshift]=linescan_xcov(mv_mpP);
[b,a]=butter(2,200/(2*mv_mpP.Tfactor));%200Hz cutoff
xc_velocity=filtfilt(b,a,xshift*mv_mpP.Xfactor*mv_mpP.Tfactor);% calculate the velocity from the displacement and filter
mv_mpP.Blood_flow.xc_velocity=xc_velocity;%velocity obtained with the cross correlation method
params.Fs=mv_mpP.Tfactor;
params.tapers=[20 39];
[S_xc,f_xc]=mtspectrumc(xshift-mean(xshift(:)),params);
mv_mpP.Blood_flow.S_xcor=S_xc;
mv_mpP.Blood_flow.f_xcor=f_xc;
mv_mpP.Blood_flow.params_xc=params;
mv_mpP.Blood_flow.xc_image=xc_image;

figure(33)
subplot(1,4,1:3)
hold off
%
imagesc((1:length(mv_mpP.Blood_flow.xc_image))/mv_mpP.Tfactor,(size(mv_mpP.Blood_flow.xc_image,1)/2:-1:-size(mv_mpP.Blood_flow.xc_image,1)/2)*mv_mpP.Tfactor*mv_mpP.Xfactor/1000,mv_mpP.Blood_flow.xc_image)
hold on
plot((1:length(mv_mpP.Blood_flow.xc_velocity))/mv_mpP.Tfactor,mv_mpP.Blood_flow.xc_velocity/1000,'w')
xlabel('time, seconds')
ylabel('velocity, mm/sec')
axis xy
subplot(1,4,4)
loglog(f_xc,S_xc)
%axis([.05 100 min(S_xc) max(S_xc)])

end

function [maxspot,xc_image,xshift]=linescan_xcov(mv_mpP)
%maxspot-amplitude of the cross correlation peak.  
%xcorr_image- power-spectra normalized cross correlation image
%xshift- shift of the peak away from the center, in pixels
x_spread=round(max(1,.5/mv_mpP.Xfactor));%spatial gaussian with 0.5um std
t_spread=round(mv_mpP.Tfactor/10);%temporal gaussian with 10ms std
the_kernel=gaussian2d(x_spread,t_spread,3*x_spread,3*t_spread);
theimage=double(mv_mpP.Blood_flow.Image);
nlines=size(theimage,2);
npoints=size(theimage,1);
average_line=mean(theimage,2);
xc_image=zeros(size(theimage));
for t=1:nlines
    theimage(:,t)=theimage(:,t)-average_line;%subtract out the background
end
for t=3:nlines
    %take the convolution of the two line-scans normalized by the joint
    %power spectrums
    xc_image(:,t)=ifft(fft(theimage(:,t)).*conj(fft(theimage(:,t-1)))./...
        sqrt(abs(fft(theimage(:,t))).*abs(fft(theimage(:,t-1)))));
end
%convolve with a gaussian space-time kernel to average velocity  
xc_image=conv2(fftshift(xc_image,1),the_kernel, 'same');%fftshift puts the lower absolute values for the velocities togetehr in the middel of the matrix,then we filter with a matched kernel 
[~,maxspot]=max(xc_image(:,:));%find the peak in the cross correlation
xshift=(round(npoints/2)-maxspot);
end

function [data]=gaussian2d(xstd,ystd,xsize,ysize)
%2-d gaussian kernel for filtering
data=zeros(xsize-1,ysize-1);
x0=xsize/2;
y0=ysize/2;
for x=1:xsize-1
    for y=1:ysize-1
        data(x,y)=exp(-((x-x0)^2)/(2*xstd)-((y-y0)^2)/(2*ystd));
    end
end
data=data/sum(data(:));
end
