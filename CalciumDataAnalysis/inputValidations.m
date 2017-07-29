for idx = 1:numFiles
    %% Verify data dimensions
    modulu = mod(size(files(idx).name, 3), 10);
    if modulu ~= 0
       warning('Wrong size for third dimension of data. Cropping the stack automatically.');
       files(idx).name = files(idx).name(:, :, 1:end-modulu);
    end

    if size(files(idx).name, 1) ~= FOV(1)
       warning('Wrong size for first dimension of data. Make sure it equals %d.\n Tiff stack will not be analyzed.', FOV(1));
       files(idx) = [];

    end

    if size(files(idx).name, 2) ~= FOV(2)
       warning('Wrong size for second dimension of data. Make sure it equals %d.\n Tiff stack will not be analyzed.', FOV(2));
       files(idx) = [];
    end

    %% Check whether it's a TAC file or not   
    isTACFile = true;
    condition = regexp(files(idx).filename, '\d+_([a-zA-Z]{3,5})_DAY', 'tokens');
    if isempty(condition)
       isTACFile = false;
       fprintf(['File was detected to not be a TAC file due to invalid file name.\n', ...
                'If this is wrong please wait for the algorithm to finish and run it from section three.\n']);
           
    end
end