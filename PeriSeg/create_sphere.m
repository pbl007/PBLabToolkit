function points=create_sphere(array_size,center,radius)
[cx,cy,cz]=ind2sub(array_size,center);
points=zeros(1,(2.*radius).^3);
counter=1;
for l=-radius:radius
    for k=-radius:radius
        for m=-radius:radius
            if l^2+k^2+m^2<=radius^2 && cx+l<=array_size(1) && cy+k<=array_size(2) && cz+m<=array_size(3) &&...
                    cx+l>=1 && cy+k>=1 && cz+m>=1
                points(counter)=sub2ind(array_size,cx+l,cy+k,cz+m);
                counter=counter+1;
            end
        end
    end
end
points(points==0)=[];
end