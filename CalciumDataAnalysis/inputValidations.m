for idx = 1:numFiles
   if mod(size(files(idx).name, 3), 10) ~= 0
       error('Wrong size for third dimension of data.');
   end
   
   if size(files(idx).name, 1) ~= FOV(1)
       warning('Wrong size for first dimension of data. Make sure it equals %d.\n Tiff stack will not be analyzed.', FOV(1));
       files(idx) = [];
   end
   
   if size(files(idx).name, 2) ~= FOV(2)
       warning('Wrong size for second dimension of data. Make sure it equals %d.\n Tiff stack will not be analyzed.', FOV(2));
       files(idx) = [];
   end 
end