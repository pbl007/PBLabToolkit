function stk  = flextiffread (varargin)
% funtion flextiffread reads gray level multitif files and returns a stack.
% Usage:
%   stk = flextiffread  - proompts user to point to file
%   stk = flextiffread (file_path) attempts to read tiff file pointed by file_path
%
%   flextiffread can also get specific portions of a stack, either sub-volumes or specific (contiguous) lines across
%   differnt frames.
%
%   For sub-volumes use:
%   stk = flextiffread(file_path,subVolRCZ) where subVol is a structure with the following fields
%         R = [start end]
%         C = [start end]
%         Z = [start end]
%
%   For lines use
%   stk = flextiffread(file_path,linesIDs) where linesIDs is a two elenent vector wiht [firstLine LastLine];
%
%Created by Pablo Blinder
%Last updated 20-Nov-2015

stk = [];
readSubVol = 0;
readLines = 0;
%parse input arguments

if nargin<1
    [file,path] = uigetfile({'*.tif';'*.tiff'});
    ptr2file = fullfile(path,file);
elseif nargin == 1
    ptr2file = varargin{1};
elseif nargin == 2
    ptr2file = varargin{1};
    subVol = varargin{2};
    if isstruct(subVol)
        readSubVol = 1;
    else
        readLines = 1;
        lineIDs = subVol;
    end
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

if readSubVol==0 & readLines==0
    %get full stack
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
    
    
    return
end

%got here so either read entire block or lines
if readSubVol
    
    %read subVolume
    nframes = diff(subVol.Z);
    bitDepth = stkinfo(1).BitDepth;
    switch bitDepth
        case 8;
            bitPerPix = 'uint8';
        case 16
            bitPerPix = 'uint16';
    end
    stk = zeros (diff(subVol.R)+1, diff(subVol.C)+1, nframes,bitPerPix);
    stkfr = 1;
    for fr = subVol.Z(1) : subVol.Z(2)
        stk (:,:,stkfr) = imread(ptr2file,fr,'PixelRegion',{[subVol.R(1) subVol.R(2)] [subVol.C(1) subVol.C(2)]});
        stkfr = stkfr + 1;
    end
    
else
    %reading lines
    %fine lines and create subVolume.
    %     LUT [frameNum lineWithinFrame]
    lineLUT = reshape([ floor(lineIDs'/stkinfo(1).Height+1)  mod(lineIDs',stkinfo(1).Height)],2,2);
    if lineLUT(1,2)==0;lineLUT(1,2)=1;end
    if lineLUT(2,2)==0;lineLUT(2,2)=stkinfo(1).Height;end
    
    %there are two cases
    nFrames2getLines = diff(lineLUT(:,1));
    if nFrames2getLines==0
        %1 - all lines are in the same frame
        subVol = struct('R',[lineLUT(1,2) lineLUT(2,2)],'C',[1 stkinfo(1).Width],'Z',[lineLUT(1,1) lineLUT(2,1)]);
        stk = flextiffread(ptr2file,subVol);
    else
        %2 - lines span several frames, read in three or two subblocks subblocks:
        % n lines from first 
        % n full frames 
        % n lines from last, then concatenate
        %get all frames minus last one
        subVol = struct('R',[lineLUT(1,2) stkinfo(1).Height],'C',[1 stkinfo(1).Width],'Z',[lineLUT(1,1) lineLUT(1,1)]);
        linesInFirstStack = flextiffread(ptr2file,subVol);
        linesInBetween  = [];
        if nFrames2getLines>2
            %get frames between first and last
            subVol = struct('R',[1 stkinfo(1).Height],'C',[1 stkinfo(1).Width],'Z',[lineLUT(1,1)+1 lineLUT(2,1)-1]);
            linesInBetween = flextiffread(ptr2file,subVol);
        end
        %get required lines from last frame
        subVol = struct('R',[1 lineLUT(2,2)],'C',[1 stkinfo(1).Width],'Z',[lineLUT(2,1) lineLUT(2,1)]);
        linesInLastFrame = flextiffread(ptr2file,subVol);
        
        %concatenate
        [r,c,z] = size(linesInBetween);
        stk = cat(1,linesInFirstStack,reshape(permute(linesInBetween,[1 3 2]),[r*z,c]),linesInLastFrame);
    end
    
end

