function neuron = NeuroLucida2Mat (filename)

% we will process each line separatedly and define what line "types":
%
% Feature definition -
%     "Cell Body", "Dendrite" or "Axon"
%
% Feature termination -
%       End of contour - finishes Cell Body
%       ( - finishes a segment
%        Normal/Incomplete terminate branches
%       |
%       )  ;  End of split - ends of an entire branch

clc
neuron = struct('CellBody',[],'Dendrites',[],'Axon',[]);
iCountoursInCellBody = 0;
numOfAxons=0;
numOfDendrites=0;


fid = fopen(filename,'r');
while 1
    currentLine = fgetl(fid);
    if ~ischar(currentLine), break,
        
    elseif ~isempty(strfind(currentLine,'Cell')) && ~isempty(strfind(currentLine,'Body'))
        disp('Working on cell body')
        iCountoursInCellBody = iCountoursInCellBody+1;
        thisCountourCoord =[];
        %call function to get cell body
        %get two lines - these do not contain numeric data
        currentWorkingLine = fgetl(fid); % first line doesn't contain data
        currentWorkingLine = fgetl(fid); % second line doesn't contain data
        %cycle to
        moreCellData = 1;
        ind = 1;
        while moreCellData
            currentWorkingLine = fgetl(fid);
            currentData=textscan(currentWorkingLine,'(%n%n%n%n) ;%n,%n');
            if strfind(currentWorkingLine,'End of contour');break;
            elseif ~isempty(currentData{1})
                % end of countour - end of cell body
                thisCountourCoord(ind,:) = cell2mat(currentData(:,1:3));%get the first three numbers
                width(ind,:)=cell2mat(currentData(:,4));
                ID(ind,:)=cell2mat(currentData(:,5:6));
                ind = ind+1;
            end
            
        end
        neuron.CellBody.ContourLine(iCountoursInCellBody).coords = thisCountourCoord;
        neuron.CellBody.ContourLine(iCountoursInCellBody).width = width;
        neuron.CellBody.ContourLine(iCountoursInCellBody).ID = ID;
        
    elseif ~isempty(strfind(currentLine,'Axon'))
        disp('Working on axon');
        numOfAxons=numOfAxons+1;
        contInd=1;
        currentWorkingLine = fgetl(fid);
        currentData=textscan(currentWorkingLine,'(%n%n%n%n)');
        neuron.Axon(numOfAxons).ContourLine(1).coords=cell2mat(currentData(:,1:3));
        neuron.Axon(numOfAxons).ContourLine(1).width(:) = cell2mat(currentData(:,4));
        neuron.Axon(numOfAxons).ContourLine(1).ID = [0 0];
        
        currentBranch=0;
        line=0;
        while 1
            
            currentWorkingLine = fgetl(fid);
            currentData=textscan(currentWorkingLine,'(%n%n%n)'); %repmat('%n',1,3)
            if ~isempty(strfind(currentWorkingLine,'End of tree'))
                break
            elseif ~isempty(currentData{1})
                if ~isempty(strfind(currentWorkingLine,'R'))
                    contInd=contInd+1;
                    line=0;
                    currentBranch=currentBranch+1;
                    tempSplit=currentWorkingLine(strfind(currentWorkingLine,'R'):end);
                    tempSplit(tempSplit=='R' | tempSplit=='-')=[];
                    if isempty(tempSplit)
                        trunkID=0;
                    else
                        trunkID=str2double(tempSplit);
                    end
                end
                
                line=line+1;
                currentData=textscan(currentWorkingLine,'(%n%n%n%n) ;%n');
                neuron.Axon(numOfAxons).ContourLine(contInd).coords(line,:) = cell2mat(currentData(:,1:3));
                neuron.Axon(numOfAxons).ContourLine(contInd).width(line,:) = cell2mat(currentData(:,4));
                neuron.Axon(numOfAxons).ContourLine(contInd).ID(line,:) = [trunkID cell2mat(currentData(:,5))];
            end
        end
        
        
    elseif ~isempty(strfind(currentLine,'Dendrite'))
        disp('Working on dendrite');
        numOfDendrites=numOfDendrites+1;
        contInd=1;
        currentWorkingLine = fgetl(fid);
        currentData=textscan(currentWorkingLine,'(%n%n%n%n)');
        neuron.Dendrites(numOfDendrites).ContourLine(1).coords=cell2mat(currentData(:,1:3));
        neuron.Dendrites(numOfDendrites).ContourLine(1).width(:) = cell2mat(currentData(:,4));
        neuron.Dendrites(numOfDendrites).ContourLine(1).ID = [0 0];
        
        currentBranch=0;
        line=0;
        while 1
            
            currentWorkingLine = fgetl(fid);
            currentData=textscan(currentWorkingLine,'(%n%n%n)'); 
            if ~isempty(strfind(currentWorkingLine,'End of tree'))
                break
            elseif ~isempty(currentData{1})
                if ~isempty(strfind(currentWorkingLine,'R'))
                    contInd=contInd+1;
                    line=0;
                    currentBranch=currentBranch+1;
                    tempSplit=currentWorkingLine(strfind(currentWorkingLine,'R'):end);
                    tempSplit(tempSplit=='R' | tempSplit=='-')=[];
                    if isempty(tempSplit)
                        trunkID=0;
                    else
                        trunkID=str2double(tempSplit);
                    end
                end
                
                line=line+1;
                currentData=textscan(currentWorkingLine,'(%n%n%n%n) ;%n');
                neuron.Dendrites(numOfDendrites).ContourLine(contInd).coords(line,:) = cell2mat(currentData(:,1:3));
                neuron.Dendrites(numOfDendrites).ContourLine(contInd).width(line,:) = cell2mat(currentData(:,4));
                neuron.Dendrites(numOfDendrites).ContourLine(contInd).ID(line,:) = [trunkID cell2mat(currentData(:,5))];
            end
        end
    end
    
    
end%non empty type of line
%figure out line type (numeric, feature (axo


fclose(fid);
save(filename(1:(end-4)),'neuron');
end

