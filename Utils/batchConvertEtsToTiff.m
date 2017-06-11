%batch convert CellSens data (recursive search for ets files);
%Dependencies 
%    - imreadBF     - PBLabToolkit/External/imreadBioFormat/
%    - rdir              - PBLabToolkit/External/Enhanced_rdir/
%    - maketiff      - PBLabToolkit/Utils/
%
% Pablo - 


%define source and target dirs
ptr2etsDir = '/data/Alisa/Confocal_images/scanner_dungeon/';
ptr2tifDir = '/data/Alisa/Confocal_images/scanner_dungeon_tiffs/';

%nubmer of channels is the only parameter to set
nChannels = 4;


%ensure target dir exists
if ~isdir(ptr2tifDir);mkdir(ptr2tifDir);end



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
        catch 
            warning('Failed to convert current channel');
        end
    end
end

fprintf('\nDone!')