%cycle directory, load si-tiffs, split channels and save a max projection for each.
%batch mode will recursively look for folders wihtin the root path

path2root_source = '/Users/pb/Dropbox/__Manuscripts/CpG_microlgia_BrM_paper/ForSubmission/PlosBiology/revision/BBB/BBB_InVivo/restack/';
path2root_dest = '/Users/pb/Dropbox/__Manuscripts/CpG_microlgia_BrM_paper/ForSubmission/PlosBiology/revision/BBB/BBB_InVivo';

nChannels = 2;
frameSize = [512 512];
nSlices =  31;

%% no need to change code below this line
dirs = rdir([path2root_source filesep '**' filesep],'isdir==1');
ndirs = numel(dirs);

%% prepare destination root
if ~isdir(path2root_dest);
    mkdir(path2root_dest)
end

%%
for iDIR = 1 : ndirs
    path2source = dirs(iDIR).name;
    
    fprintf('\nWorking on  %s',path2source);
    
    %prpare destination directory based on name of current source
    pathdiff=erase(path2source,path2root_source);
    
    this_path2dest = fullfile(path2root_dest,pathdiff);
    
    
    %%
    dirContent = dir([path2source filesep '*.tif']);
    
    nFILES = numel(dirContent);
    % create destination directoris if not present
    
    if nFILES>0
        targetDir = cell(nChannels,1);
        for iCH =1 : nChannels
            targetDir{iCH} = fullfile( this_path2dest,sprintf('Ch_%02d',iCH));
            if ~isdir(targetDir{iCH})
                mkdir(targetDir{iCH});
            end       
        end
        
        %% create stack for max projection for each channels
        max_proj_stack = zeros([frameSize nFILES nChannels],'uint16');
        
        for iFILE = 1:nFILES
            %     obj = ScanImageTiffReader(fullfile(path2source,dirContent(iFILE).name));
            
            f= dirContent(iFILE).name;
            
            for iCH = 1 : nChannels
                %opting to use the opentif.m util (borrowed from +scanimge::+utils - note scanimage has to be in path.
                [~,stk]=opentif(fullfile(path2source,dirContent(iFILE).name),'channel',iCH);
                %opentif retuns a 5D file, redundant here so squeeze to get MxNxF where F is number of frames in stack
                stk = squeeze(stk);
                thisMaxProjName = sprintf('MAX_%s',dirContent(iFILE).name);
                thisProj = max(stk(:,:,15:25),[],3);
                %   thisProj = sum(stk,3)-double(median(stk,3));
               maketiff(uint16(thisProj),fullfile(targetDir{iCH},thisMaxProjName));
                
                max_proj_stack(:,:,iFILE,iCH) = uint16(thisProj);
            end
        end
        
        
        %% write stacked max proj to file, on parent dir relative to the single max projections 
        [~, filename ] = fileparts (dirContent(iFILE).name);
        filename = filename(1:end-6); %We remove the last 5 digits and one '_'
        
        %%
        for iCH = 1 : nChannels
            stk_file_name = fullfile(this_path2dest,['MAX_' filename '-Ch' num2str(iCH) '.tif']);
            maketiff(max_proj_stack(:,:,:,iCH),stk_file_name);
        end
        
    else
        fprintf('\tNo files found');
    end %working on current directory with nFILES>0
    
end%recursively cycling directories