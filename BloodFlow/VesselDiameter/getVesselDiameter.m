function [mv_mpP]=getVesselDiameter(orig_fname, fname, theimage, expInfo)
%this function takes a tiff file (movie) and an analog ascii file, and
%extracts the diameters - original by Patrick Drew
%
% Inputs:
% orig_fname - string - full path to multitiff before splitting it to two
% channels.   
% fname - string - FULL path to multitiff after the split
% expInfo - struct - description of parameters:
%               .Magnification - double
%               .Rotation - double
%               .FrameRate - double
%               .startToEndFrames 2-element vector with frames to be used  [start end]
%               .nVessels - number of vessels to manually select
%               .micronsPerPixelAt1x - double, how many microns in FOV at x1 magnification
%               .animal_ID, string
%               .FOV_ID, string indicates field of view identifier
% theimage - the data loade into memory


%Read header and take further action based on header information
%Modified by Pablo Blinder

%open tif file and display first frame
% cd='Z:\Amos\optogenetics\29Jun17_opto';%AG added
% theimage=imread(fname,'TIFF','Index',1);
figure(2)
imagesc(double(theimage(:, :, 1)))
axis image
axis off


%walking_analog=load(analog_trace);
%get file info
Info = imfinfo(orig_fname);
mv_mpP(1).Header.Filename=Info(1).Filename;
mv_mpP(1).Header.Frame_Width = num2str(Info(1).Width);
mv_mpP(1).Header.Frame_Height = num2str(Info(1).Height);
mv_mpP(1).Header.num_frames= length(Info);
mv_mpP(1).xsize = str2double(mv_mpP(1).Header.Frame_Width);
mv_mpP(1).ysize = str2double(mv_mpP(1).Header.Frame_Height);
nframes=length(Info)
mv_mpP(1).num_frames=nframes;
mv_mpP(1).Header.Frame_Count=nframes;

%In the original code, Patrick takes this data from the tiff header, we provide it as input argument in expInfo struct
mv_mpP(1).Header.Magnification=expInfo.Magnification;
mv_mpP(1).Header.Rotation=expInfo.Rotation;
mv_mpP(1).Header.Frame_Rate=expInfo.FrameRate;

%Read header and take further action based on header information

if isfield(expInfo,'startToEndFrames')
    mv_mpP(1).startframe=expInfo.startToEndFrames(1);
    mv_mpP(1).endframe=expInfo.startToEndFrames(2);
else
    mv_mpP(1).startframe=input('start frame: ');
    mv_mpP(1).endframe=input('end frame: ');
end

if isfield(expInfo,'nVessels')
    nvessels = expInfo.nVessels;
else
    nvessels=input('# of vessels on this slice:');
end

mv_mpP(1).nframes_trial=NaN;%input('how many frames per trial?')
%mv_mpP(1).the_stim=the_stim;

the_decimate=1;%input('decimation factor: '); only for oversampled data

if isfield(expInfo,'micronsPerPixelAt1x')
    microns_per_pixel = expInfo.micronsPerPixelAt1x;
else
    microns_per_pixel=input('microns per pixel @ 1x: ');
end
mv_mpP(1).microns_per_pixel=microns_per_pixel;

if isfield(expInfo,'animal_ID')
    animal = expInfo.animal_ID;
else
    animal=input('animal ID','s');
end

if isfield(expInfo,'FOV_ID')
    FOV_ID = expInfo.FOV_ID;
else
    FOV_ID=input('FOV ID?' ,'s');
end

% the_objective=input('objective: [1] 40x Olympus; [2] 20x: [3] 20x,0.95na [4] 10x [5] 4x: ');

%the_scanmirrors=2;%input('which mirrors? 1)6210(fast) 2)6215(slow)')

vesselcount=1;
frame_rate= mv_mpP(1).Header.Frame_Rate;
Pixel_clock=1/((5/4)*frame_rate*mv_mpP(1).xsize*mv_mpP(1).ysize)
time_per_line= (mv_mpP(1).Header.Frame_Width)*(5/4)*Pixel_clock*(.05*1e-6);
mv_mpP(1).Header.time_per_line=1/(frame_rate*str2double(mv_mpP(1).Header.Frame_Height));
Xfactor=microns_per_pixel/(str2double(mv_mpP(1).Header.Magnification(2:end)))
mv_mpP(1).microns_per_pixel=microns_per_pixel;
if (nvessels>0)
    
    ystring=['y'];
    theinput=['n'];
    xsize=size(theimage,2);
    ysize=size(theimage,1);
    Y=repmat([1:ysize]',1,xsize);
    X=repmat([1:xsize],ysize,1);
    
    for vesselnumber=1:nvessels
        mv_mpP(vesselnumber)=mv_mpP(1);
        area = impoly(gca,[1 1; 1 20;20 20;20 1]);
        while (strcmp(ystring,theinput)~=1)
            theinput=input('diameter box ok? y/n \n','s');
        end
        
        if    strcmp(ystring,theinput)
            api = iptgetapi(area);
            mv_mpP(vesselnumber).Vessel.box_position.xy=api.getPosition();
            mv_mpP(vesselnumber).Vessel.xsize=xsize;
            mv_mpP(vesselnumber).Vessel.ysize=ysize;
            theinput=['n'];
        end
        diam_axis=imline(gca,round(xsize*[.25 .75]),round(ysize*[.25 .75]));
        while (strcmp(ystring,theinput)~=1)
            theinput=input('diameter axis ok? y/n \n','s');
        end
        if    strcmp(ystring,theinput)
            api = iptgetapi(diam_axis);
            mv_mpP(vesselnumber).Vessel.vessel_line.position.xy=api.getPosition();
            theinput=['n'];
        end
        mv_mpP(vesselnumber).Xfactor=Xfactor;
    end
    mv_mpP=GetDiametersFromMovie_Tiff_01(mv_mpP, theimage);
    %    mv_mpP(1).Analog.walking=walking_analog;
    
end

ntrials=1;%input
the_date=date;
try
    [mv_mpP]=FWHMfromMovieProjection2(mv_mpP,[mv_mpP(1).startframe mv_mpP(1).endframe] )
catch
    disp('plot fail')
end

[path2dir,fname] = fileparts(fname);
save_filename=[animal '_' FOV_ID '_mv_mpP_' fname '_' the_date];
% [mv_mpP]=PlotMovieDiameters_walking(mv_mpP,walking_analog,1);%original
[mv_mpP]=PlotMovieDiameters_walking(mv_mpP,[],1);


try
    save(fullfile(path2dir,save_filename),'mv_mpP')%save processed file to current directory
    fprintf('\n Saved last analysis to %s',fullfile(path2dir,save_filename));
    %    save(['f:\data\crunched\' save_filename],'mv_mpP')%save to crunched directory
catch
    disp('crunched folder save failed!')
end


end


function [mv_mpP]=PlotMovieDiameters_walking(mv_mpP,walking_analog,basefignum)
%plots episodic movie diameters
%walking data is plotted as well
nvessels=length(mv_mpP);
%cm_per_volt=38.4;
%stimcolor={'b' 'r'};
vessel_colors={'g' 'c' 'm' 'y' 'r' 'k' 'g' 'c' 'm' 'y' 'r' 'k' };
figure(basefignum)
subplot(3,2,6)
hold off
imagesc((1:size(mv_mpP(1).first_frame,2))*mv_mpP(1).microns_per_pixel/(mv_mpP(1).Header.Magnification),(1:size(mv_mpP(1).first_frame,1))*mv_mpP(1).microns_per_pixel/(mv_mpP(1).Header.Magnification), ...
    medfilt2(double(max(0,(mv_mpP(1).first_frame-.5*median(mv_mpP(1).first_frame(:)))))))
axis image
colormap gray
hold on
axis off


%in the original code the diameter is indexed from 2:end this is OK as long as all frames are used, boo-boo if not (i.e.
%user specified different start end frames. Now corrected - PB

frameStart = mv_mpP.startframe;
frameEnd = mv_mpP.endframe;

duration=length(mv_mpP(1).Vessel.diameter(frameStart:frameEnd))/(mv_mpP(1).Header.Frame_Rate);
the_fs=1/mv_mpP(1).Header.Frame_Rate;
the_NW=floor(max(1,the_fs*duration/2));


for mv=1:nvessels
    mv_mpP(mv).Vessel.diameter=(mv_mpP(1).microns_per_pixel/(mv_mpP(1).Header.Magnification))*mv_mpP(mv).Vessel.raw_diameter;
    plot(mv_mpP(1).microns_per_pixel/(mv_mpP(1).Header.Magnification)*[mv_mpP(mv).Vessel.box_position.xy(:,1)' mv_mpP(mv).Vessel.box_position.xy(1,1)],...
        mv_mpP(1).microns_per_pixel/(mv_mpP(1).Header.Magnification)*[mv_mpP(mv).Vessel.box_position.xy(:,2)' mv_mpP(mv).Vessel.box_position.xy(1,2)],vessel_colors{mv},'LineWidth',3);
end
max_plot_time=max(length(mv_mpP(mv).Vessel.diameter(1:end))/(mv_mpP(1).Header.Frame_Rate));
frame_times=((1:length(mv_mpP(mv).Vessel.diameter(frameStart:frameEnd)))/(mv_mpP(1).Header.Frame_Rate));
subplot(3,1,1)
%plot(walking_analog(:,1),(walking_analog(:,2)*cm_per_volt))

xlabel('sec')
ylabel('cm/sec')
axis([0 max_plot_time -5 12 ])
subplot(3,1,2)
hold off
params.Fs=(mv_mpP(1).Header.Frame_Rate);
params.tapers=[the_NW 2*the_NW-1];
params.err=[1 .01];
params.fpass=[0.03 3]
for mv=1:nvessels
    plot((1:length(mv_mpP(mv).Vessel.diameter(frameStart:frameEnd)))/(mv_mpP(1).Header.Frame_Rate),medfilt1(mv_mpP(mv).Vessel.diameter(frameStart:frameEnd),5),[vessel_colors{mv}],'LineWidth',3);
    hold on
    [S{mv},f{mv},Serr{mv}]=mtspectrumc(mv_mpP(mv).Vessel.diameter(frameStart:frameEnd)-mean(mv_mpP(mv).Vessel.diameter(frameStart:frameEnd)),params);
    [diff_S{mv},diff_f{mv},diff_Serr{mv}]=mtspectrumc(diff(mv_mpP(mv).Vessel.diameter(frameStart:frameEnd)),params);
    [volume_S{mv},volume_f{mv},volume_Serr{mv}]=mtspectrumc((mv_mpP(mv).Vessel.diameter(frameStart:frameEnd).^2),params);
    mv_mpP(mv).S=S{mv};
    mv_mpP(mv).f=f{mv};
    mv_mpP(mv).diff_S=diff_S{mv};
    mv_mpP(mv).diff_f=diff_f{mv};
    mv_mpP(mv).volume_S=volume_S{mv};
    mv_mpP(mv).volume_f=volume_f{mv};
end
axis([0 max_plot_time 0 1.1*max(mv_mpP(mv).Vessel.diameter)]);
title(['vessel diameters'])
xlabel('time, seconds')
ylabel('diameter, um')
title(mv_mpP(1).Header.Filename)

subplot(3,2,5)
hold off
for mv=1:nvessels
    loglog(f{mv},S{mv},vessel_colors{mv});
    hold on
end
axis([ 0.03 3  1e-4 5])
axis square


end


% function mv_mpP=GetDiametersFromMovie_Tiff_01(mv_mpP, fname)
% Changed by Hagai so the file won't have to be read twice (!)
function mv_mpP=GetDiametersFromMovie_Tiff_01(mv_mpP, stack)
%this function opens the tiff file and gets the  vessel projections from the defined polygons
mv_mpP(1).first_frame = stack(:, :, 1);

%mp2mat_getChannelData_narrow_noplot(mpfile,1,mv_mpP(1), [1 1],[1 mv_mpP(1).xsize]);
fft_first_frame=fft2(double(mv_mpP(1).first_frame));
for mv=1:length(mv_mpP)
    
    Y=repmat([1:mv_mpP(1).ysize]',1,mv_mpP(1).xsize);
    X=repmat([1:mv_mpP(1).xsize],mv_mpP(1).ysize,1);
    mv_mpP(mv).Vessel.projection_angle=atand(diff(mv_mpP(mv).Vessel.vessel_line.position.xy(:,1))/diff(mv_mpP(mv).Vessel.vessel_line.position.xy(:,2)));
    atand(diff(mv_mpP(mv).Vessel.vessel_line.position.xy(:,1))/diff(mv_mpP(mv).Vessel.vessel_line.position.xy(:,2)))
    
   for theframe=(mv_mpP(mv).startframe):mv_mpP(mv).endframe
        raw_frame =stack(:, :, theframe);%(mp2mat_getChannelData_narrow_noplot(mpfile,1,mv_mpP(1), [theframe theframe],[1 mv_mpP(1).xsize]));
        fft_raw_frame=fft2(double(raw_frame));
        if mv==1
            [mv_mpP(mv).pixel_shift(:,theframe), Greg]=dftregistration(fft_first_frame,fft_raw_frame,1);
        end
        inpoly_frame = inpolygon(X-mv_mpP(1).pixel_shift(3,theframe),Y-mv_mpP(1).pixel_shift(4,theframe),mv_mpP(mv).Vessel.box_position.xy(:,1),mv_mpP(mv).Vessel.box_position.xy(:,2));
        bounded_raw_frame=raw_frame.*uint16(inpoly_frame);
        mv_mpP(mv).Vessel.projection(theframe,:)=radon(bounded_raw_frame,mv_mpP(mv).Vessel.projection_angle);
    end
end
figure(4444)
imagesc( mv_mpP(mv).Vessel.projection)

end


function [mv_mpP]=FWHMfromMovieProjection2(mv_mpP,theframes)
%gets dameters from movie projections
vessel_colors={'b' 'r' 'g' 'k' 'c' 'm' 'y'}
stimcolor={'b' 'r'}
for mv=1:length(mv_mpP)
    for k=min(theframes):max(theframes)
        mv_mpP(mv).Vessel.raw_diameter(k)=calcFWHM(mv_mpP(mv).Vessel.projection(k,:));
    end
    
    mv_mpP(mv).Vessel.diameter= mv_mpP(mv).Vessel.raw_diameter*mv_mpP(1).Xfactor;
    mv_mpP(mv).Vessel.mean_diameter = mean(mv_mpP(mv).Vessel.diameter);
    mv_mpP(mv).Vessel.std_diameter = std(mv_mpP(mv).Vessel.diameter);
end
end


function width = calcFWHM(data,smoothing,threshold)
% function which takes data and calculates the full-width, half max value
% half-max values are found looking in from the sides, i.e., the program will work
% even if the data dips to a lower value in the middle
% 2009-06-17 - no longer subracting the min from the entire data set
% 2009-06-17 - changed convolution to conv2, and added 'valid' parameter

data = double(data(:));     % make sure this is column, and cast to double

% smooth data, if appropriate
if nargin < 2
    % smoothing not passed in, set to default (none)
    smoothing = 1;
end

if smoothing > 1
    data = conv2(data,rectwin(smoothing) ./ smoothing,'valid');
end

% subtract out baseline
%data = data - min(data);   %jd - don't subract out min, in case threshold was set externally

if nargin < 3
    %threshold = max(data)/2;
    offset = min(data);                           % find the baseline
    threshold = max(data - offset) / 2 + offset;  % threshold is half max, taking offset into account
end

aboveI = find(data > threshold);    % all the indices where the data is above half max

if isempty(aboveI)
    % nothing was above threshold!
    width = 0;
    return
end

firstI = aboveI(1);                 % index of the first point above threshold
lastI = aboveI(end);                % index of the last point above threshold

if (firstI-1 < 1) | (lastI+1) > length(data)
    % interpolation would result in error, set width to zero and just return ...
    width = 0;
    return
end

% use linear intepolation to get a more accurate picture of where the max was
% find value difference between the point and the threshold value,
% and scale this by the difference between integer points ...
point1offset = (threshold-data(firstI-1)) / (data(firstI)-data(firstI-1));
point2offset = (threshold-data(lastI)) / (data(lastI+1)-data(lastI));

point1 = firstI-1 + point1offset;
point2 = lastI + point2offset;

width = point2-point1;
end