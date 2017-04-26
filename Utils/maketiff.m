function output_filename = maketiff(varargin);
%this function writes a 3-D image stack as a multi-frame .tif file
%use : maketiff(myvariable, output_filename)
%   this returns the output_filename
%   if output_filname is excluded, a uiputfile gui opens to select a
%   filename
%note, an extra qualifier variable can be added to the end
%   maketiff(myvariable,qualifier) or maketiff(myvariable, output_filename, qualifier)
%the qualifier can be 'transpose', or 'nowb' to either transpose the matrix
%   before writing the tif, or to eliminate the waitbar.
%
%Written by Philbert S. Tsai on 08/03/05
%Last Updated : 06/10/06


nin = nargin;
filename = ' ';
transpose_yn = 0;
waitbar_yn = 1;
input_matrix = varargin{1};
if nin>1,
    qualifier1 = varargin{2};
    switch qualifier1,
        case 'transpose', transpose_yn = 1;
        case 'notranspose', transpose_yn = 0;
        case 'nowb', waitbar_yn = 0;
        otherwise filename = varargin{2};
    end
end


if filename == ' ';
    [filename,pathname,filterindex] = uiputfile('*.tif', 'Save as multiframe tif');
    filename = [pathname,filename];
end

if nin>2,
    qualifier1 = varargin{3};
    if strcmp(qualifier1,'transpose'), transpose_yn = 1; end
    if strcmp(qualifier1,'notranspose'), transpose_yn = 0; end
    if strcmp(qualifier1,'nowb'), waitbar_yn = 0; end
end


mysize = size(input_matrix);
x_size = mysize(1);
y_size = mysize(2);
temp = size(mysize);
if temp(2) == 3,
    z_size = mysize(3);
else
    z_size = 1;
end

current_frame = input_matrix(:,:,1);
if transpose_yn == 1; current_frame = transpose(current_frame);end

finfo = whos('input_matrix');
bitDepth = finfo.class;
switch bitDepth
    case {'uint8'}
        input_matrix = uint8(input_matrix);
    case {'uint16'}
        input_matrix = uint16(input_matrix);
    case {'logical'}
        input_matrix = uint8(input_matrix.*256);
end

current_frame = input_matrix(:,:,1);
imwrite(current_frame,filename,'tiff','Compression','none');


if z_size >1,
    if waitbar_yn == 1, wb = waitbar(0,'Writing multiframe tiff...');end 
    for k = 2:z_size,
        current_frame = input_matrix(:,:,k);
        if transpose_yn == 1; current_frame = transpose(current_frame);end
        imwrite((current_frame),filename,'tiff','WriteMode','append','Compression','none');
        if waitbar_yn == 1, waitbar(k/z_size,wb), end
    end
    if waitbar_yn == 1, close(wb); end
end

output_filename = filename;

return





