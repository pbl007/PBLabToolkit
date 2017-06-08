% function MosaicTiling_displayUpdatedMosaicLayout(prmts)
%Do not create new figure but reuse while updating each block current position

h2fig = findobj('Tag',[prmts.baseName ' Mosaic Tiled'])