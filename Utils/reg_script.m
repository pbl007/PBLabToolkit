%%image registration script

% AG added flextiffread.m to the folder to read 3d matrix
% AG added maketiff.m to save a 3d tiff
%run at first time only
javaaddpath('C:\ImageJ');
javaaddpath('C:\Program Files\MATLAB\R2011b\java');
% end 

im = flextiffread;  %This reads a movie into a 3d matrix using a gui

h=waitbar(0,'Image registration processsing');

target=mean(im(:,:,1:end),3); %takes frames 1->end and average them 
                            % across time (that's the 3 for the 3rd dimention)
                            % so we get 1 matrix of the avereage image
                            %we'll use this to anchor the other frames
reg=zeros(size(im),'uint16');
% shift=zeros(1,size(im,3));

for repetitions =1:20 %to re-correct the product 20 times
        for i=1:size(im,3) %to go along the frames
        [~,temp2]=turbo_reg(im(:,:,i),target);
        % turbo_reg is an ImageJ plugin
        % http://bigwww.epfl.ch/thevenaz/stackreg/
        % http://bigwww.epfl.ch/thevenaz/turboreg/
        %place both folders (StackReg, turbo_reg) within the plugin folder of imageJ
        %the code also needs matlab to inetract with imageJ
        %on my machine: (ohers may need to change matlab version
        %and/or location)
        %javaaddpath 'C:\Program Files\MATLAB\R2011b\java\mij.jar'
        %javaaddpath 'C:\Program Files\MATLAB\R2011b\java\ij.jar'
        % AG
        
        %     shift(i,:)=temp1; (not from AG)
        reg(:,:,i)=temp2;
        waitbar(i/size(im,3))  %graphic display of the calculation progress
        end
%reg is the motion corrected movie
im=reg;
end
%save('corrected_movie','reg');%save reg into corrected_movie
%this gave me a 'dat' file but I want tif
%imwrite(reg,'corrected_movie','tiff','Compression', 'none');
%this gives me 1 frame. I guess I need to have imwrite to movie
maketiff(reg, 'corrected_movie_Dec1st10');

close(h)
%clear im AG commented so I don't need to load each time I check the code
save reg_FOV6_green reg -v7.3; %that was in the code and I don't understand this