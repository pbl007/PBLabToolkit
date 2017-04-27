function batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels,varargin)
%batchDeinterleaveChannelsInSIfiles - deinterleave multichannel from SI tif files.
%
%Usage batchDeinterleaveChannelsInSIfiles(srcDir,destDir,nChannels) - will recursively search for tif files and attempt
%to deinterleave frames into 'nChannels'. 
%
%
% Dependencies - TIFFStack
% Pablo - Apr 2017
