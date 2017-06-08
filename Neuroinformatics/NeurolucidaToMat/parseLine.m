function parsedLine = parseLine(thisLine)
% number lines have only one opening and one closing parenthesis

parsedLine = struct('type',[]);

%few lines start wiht | and represent new branch
ispipe = strfind(thisLine,'|');
if ~isempty(ispipe)
     parsedLine.type = 'Starter-trunk';
     parsedLine.content = thisLine;
     return
end

%most lines start wiht an open parenthesis

openP = strfind(thisLine,'(');
closeP = strfind(thisLine,')');

%lines wiht just an opening parenthesis that are certainly not numeric
if numel(openP)==1 && numel(closeP)==0 
   
    if openP == numel(thisLine)
        parsedLine.type = 'Starter-branch';
        parsedLine.content = thisLine;
        return
    end
    
    %the only other case where we have only one opening parenthesis is for
    % "CellBody"
     parsedLine.type = 'Feature-CellBody';
     parsedLine.content = thisLine;
     return

end
    
if numel(openP)>1 || numel(closeP)>1
%     disp('Not numeric')
    %let's find out what's in there
end

