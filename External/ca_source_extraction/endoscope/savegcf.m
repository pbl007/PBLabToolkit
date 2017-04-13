<<<<<<< HEAD
function savegcf(file_nm)
% save images in three formats: fig, png, eps
saveas(gcf, [file_nm, '.fig']); 
saveas(gcf, [file_nm, '.png']); 
=======
function savegcf(file_nm)
% save images in three formats: fig, png, eps
saveas(gcf, [file_nm, '.fig']); 
saveas(gcf, [file_nm, '.png']); 
>>>>>>> master
saveas(gcf, [file_nm, '.eps'], 'psc2'); 