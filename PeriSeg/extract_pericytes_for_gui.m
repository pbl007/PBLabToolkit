function extract_pericytes_for_gui(seeds_cc_orginized,centroids,raw_ch1,raw_ch3,filename_prefix )
len=length(seeds_cc_orginized.PixelIdxList);%amount of different pericytes should equal initial seed count
%pericytes_mats{len}=[];
C=cast(zeros([size(raw_ch1) 4]),'uint16');
C(:,:,:,1)=raw_ch1;
C(:,:,:,2)=raw_ch3;
D=cast(zeros(size(raw_ch1)),'uint16');
E=D;
for k=1:len
    [X,Y,Z]=ind2sub(size(raw_ch1),seeds_cc_orginized.PixelIdxList{k});
    [maxx,minx]=find_crop_size(size(raw_ch1,1),X,100);
    [maxy,miny]=find_crop_size(size(raw_ch1,2),Y,100);
    [maxz,minz]=find_crop_size(size(raw_ch1,3),Z,100);
    D(D>0)=0;
    E=D;

    pts=create_sphere(size(raw_ch1),centroids(k),5);
    E(pts)=65000;
    
    D(seeds_cc_orginized.PixelIdxList{k})=65000;

    C(:,:,:,3)=D;
    C(:,:,:,4)=E;
    %pericytes_mats{k}=C(minx:maxx,miny:maxy,minz:maxz,:);
    str=sprintf('%s_%d.mat',filename_prefix,k);
    seed_image=C(minx:maxx,miny:maxy,minz:maxz,:);
    save (str, 'seed_image');
end
end
    

function [maxp,minp]=find_crop_size(cordinate_length,p,min_size)
minp=round(0.8*min(p));maxp=round(1.2*max(p));
if(maxp >cordinate_length);maxp=cordinate_length;end
if(minp <1);minp=1;end
if(maxp-minp<min_size)
    expansion_length=min_size-(maxp-minp);
    half_expansion=round(expansion_length./2);
    if(maxp+half_expansion>cordinate_length)
        exapnsion_possible=cordinate_length-maxp;
        minp=minp-(expansion_length-exapnsion_possible);
        maxp=cordinate_length;
        return;
    end

    if(minp-half_expansion<1)
        exapnsion_possible=minp-1;
        maxp=maxp+(expansion_length-exapnsion_possible);
        minp=1;
        return;
    end
    if (maxp+half_expansion<=cordinate_length && minp-half_expansion>=1)
        maxp=maxp+half_expansion;
        minp=minp-half_expansion;
        return;
    end
end
return;
end