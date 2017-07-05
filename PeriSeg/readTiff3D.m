function [Mask_3D,num_images]=readTiff3D(filename)
info=imfinfo(filename);
num_images=size(info);
num_images=num_images(1);
Mask_2D=imread(filename,1,'Info',info);
Mask_3D(:,:,1)=Mask_2D;
    for index=2:num_images
        Mask_2D=imread(filename,index,'Info',info);
        Mask_3D(:,:,index)=Mask_2D;
    end
end
