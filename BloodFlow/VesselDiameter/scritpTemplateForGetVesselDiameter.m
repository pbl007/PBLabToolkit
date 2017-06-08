%script template for vessel diameter extraction

fname = '/Users/pb/Data/PBLab/David/CalciumMovieData/area 1_movie3 for arb3 mag 1 fr_4p36_airPuff-Ch2.tif';

expInfo.Magnification = 1.4;
expInfo.Rotation = 1;
expInfo.FrameRate = 4.36;
expInfo.startToEndFrames = [1 312];
expInfo.nVessels = 1;
expInfo.micronsPerPixelAt1x=0.708; 
expInfo.animal_ID='300';
expInfo.FOV_ID='1';


mv_mpP = getVesselDiameter(fname,expInfo);

%the diameter data is stored in 
%       mv_mpP.Vessel.diameter
%       mv_mpP.Vessel.mean_diameter
%       mv_mpP.Vessel.std_diameter