function write_tiff_img(img, filename)
    imwrite(img(:,:,1), filename)
    for k = 2:size(img,3)
       imwrite(img(:,:,k), filename, 'writemode', 'append');
    end
end