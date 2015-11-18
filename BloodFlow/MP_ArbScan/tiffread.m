function stk  = tiffread (varargin)
% funtion tiffread reads gray level multitif files and returns a stack.
% Usage:
%   stk = readtiff  - proompts user to point to file
%   stk = readtiff (file_path) attempts to read tiff file pointed by
%   file_path
%
%Created by Pablo Blinder
%Last updated 04-Dec-2006

stk = [];

%parse input arguments
if nargin<1
   [file,path] = uigetfile({'*.tif';'*.tiff'});
   ptr2file = fullfile(path,file);
else
   ptr2file = varargin{1};
end

%get info and find out number of frames, abort if not a gray level imge
stkinfo = imfinfo(ptr2file);
if length (stkinfo) < 1
   disp ('file contains no frames');
   return
elseif ~strcmp(stkinfo(1).ColorType,'grayscale')
   disp ('file contains no frames');
   return
end

% if got here, read frames
nframes = length(stkinfo);
bitDepth = stkinfo(1).BitDepth;
switch bitDepth
   case 8;
       bitPerPix = 'uint8';
   case 16
       bitPerPix = 'uint16';
end
stk = zeros (stkinfo(1).Height, stkinfo(1).Width, nframes,bitPerPix);
for fr = 1 : nframes
   stk (:,:,fr) = imread(ptr2file,fr);
end