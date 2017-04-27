function batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels,varargin)
%batchDeinterleaveChannelsInSIfiles - deinterleave multichannel from SI tif files.
%
%Usage batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels) - will recursively search for tif files and attempt
%to deinterleave frames into 'nChannels'. 
%
%
<<<<<<< Updated upstream
% Dependencies - TIFFStack
% Pablo - Apr 2017
=======
% Dependencies - TIFFStack, Enhanced_rdir, all appear in ../external
% Pablo - Apr 2017

%%
dirContent = rdir(fullfile(srcDir,'**/*.tif'));


%ensure destination exists
if ~isdir(destDir),mkdir(destDir);end
>>>>>>> Stashed changes
