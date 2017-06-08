function neuronStruct = NeuroLucidaToMat (filename)

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
neuronStruct = struct('CellBody',[],'Dendrites',[],'Axon',[]);
iCountoursInCellBody = 0;


fid = fopen(filename,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    parsedLine = parseLine(tline);

    if ~isempty(parsedLine.type)
        
        thisLineType= parsedLine.type;
        switch thisLineType
            case 'Feature-CellBody'
                disp('Cell body')
                iCountoursInCellBody = iCountoursInCellBody+1;
                thisCountourCoord =[];
                %call function to get cell body
                %get two lines - these do not contain numeric data
                thisLine = fgetl(fid);
                thisLine = fgetl(fid);
                %cycle to
                moreCellData = 1;
                iPoint = 1;
                while moreCellData
                    thisLine = fgetl(fid);
                    if strfind(thisLine,'End of contour');break;end
                    thisCountourCoord(iPoint,:) = cell2mat(textscan(thisLine,'(%n%n%n)'));%get the first three numbers
                    iPoint = iPoint+1;
                    
                end
                neuronStruct.CellBody.ContourLine(iCountoursInCellBody).coords = thisCountourCoord;
            case 'Starter-branch'
                disp('got branch')
                
            case 'Starter-trunk'
                disp('got trunk')
        end
        
    end%non empty type of line
    %figure out line type (numeric, feature (axo
    
end
fclose(fid);

