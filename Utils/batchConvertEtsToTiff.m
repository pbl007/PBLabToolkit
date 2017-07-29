%batch convert CellSens data (recursive search for ets files);v
%Dependencies 
%    - imreadBF     - PBLabToolkit/External/imreadBioFormat/
%    - rdir              - PBLabToolkit/External/Enhanced_rdir/
%    - maketiff      - PBLabToolkit/Utils/
%
% Pablo - 

% %% add path
% PBLabToolKitRoot = '/data/MatlabCode/PBLabToolkit/';
% 
% addpath(fullfile(PBLabToolKitRoot,'External/imreadBioFormat'));
% addpath(fullfile(PBLabToolKitRoot,'External/Enhanced_rdir'));
% addpath(fullfile(PBLabToolKitRoot,'Utils'));


%this change between servers...
dataRoot = '/data'; %stromboli


%define source and target dirs
ptr2etsDir = fullfile(dataRoot,'/data/Alisa/Confocal_images/scanner_dungeon/viptd_neta');
ptr2tifDir = fullfile(dataRoot,'/Alisa/Confocal_images/scanner_dungeon/viptd_neta');

%nubmer of channels is the only parameter to set
nChannels = 3;


%ensure target dir exists
if ~isdir(ptr2tifDir);mkdir(ptr2tifDir);end


%%
dirContent = rdir([ptr2etsDir '/**/*.ets']);
nFiles = length(dirContent);

for iFILE = 1 : nFiles
    etsName = regexp(dirContent(iFILE).name,'/(_Tile.*?)/stack','tokens'); %we extract the numers between _XXX_ form the folder name, expecting
    etsName = etsName{1}{1}(1:end-1);
    
    parfor iCH = 1 : nChannels
        fprintf('\nFile (%d/%d) \t %s (Ch%02d) started at %s',iFILE,nFiles,etsName,iCH,datestr(now,31))
        tifName = sprintf('%s-Ch%02d.tif',etsName,iCH);
        path2ets = dirContent(iFILE).name;
        path2tif = fullfile(ptr2tifDir,tifName);
        %load, make uint16 and write tiff
        try
        img = uint16(imreadBF(path2ets,1,1,iCH));
        maketiff(img,path2tif);
        
        %create "thumbnail"
        path2png = strrep(path2tif,'.tif','.png');
        imwrite(imadjust(imresize(img,0.125)),path2png);
        catch 
            warning('Failed to convert current channel - %s', lasterr); %#ok<LERR>
        end
    end
end

fprintf('\nDone!')