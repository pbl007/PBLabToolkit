function T = convertExpFromETStoTIF(T,expStructure)
% convertExpFromETStoTIF walks along the entries of an experiment table T and converts each ets file to separated tif
% files in a flat directory (one per cycle as this is the focus of the stitching pipeline)
%
% Pablo -

%todo - skip existing files, update status to table

%% Parse structure fields to variables, easier for coding...
nChannels = expStructure.nChannels;

%%
nTasks = size(T,1);
taskProgress = zeros(nTasks,nChannels); %keep status tab

%%
parfor_progress(nTasks)
parfor iTASK = 1 : nTasks
    for iCH = 1 : nChannels
        try
            %             if exist(T.pathToTIF{iTASK},'file');end
            path2ets = T.pathToETS{iTASK};
            img = uint16(imreadBF(path2ets,1,1,iCH));
            
            thisChTifName = T.pathToTIF{iTASK};
            ChDelim =  regexp(thisChTifName,'[0-9]+.tif');
            thisChTifName(ChDelim:ChDelim+1)=sprintf('%02d',iCH);
            maketiff(img,thisChTifName);
            %log successful
            status = 1;
        catch
            %log failure
            status = -1;
            warning('Failed to convert channel %d',iCH);
        end
        taskProgress(iTASK,iCH)=status;
    end
    parfor_progress;
end

%update progress table (can't be done inside parfor...)
for iCH = 1 : nChannels
    cmd = sprintf('T.ch%d(:)=taskProgress(:,%d);',iCH,iCH);
    eval(cmd)
end
