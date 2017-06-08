function RawImagesMat = ImageGeneratorHist3(PhotonArray, SizeX, SizeY, StartOfFrameVec, NumOfLines, TotalEvents, MaxDiffOfLines)

RawImagesMat = zeros(SizeX, SizeY, max(size(StartOfFrameVec, 1) - 1, 1),'uint16'); % Last half-recorded frame won't be imaged
CurrentFrameNum = 1;

%% Create histograms
if (isempty(StartOfFrameVec) && (NumOfLines == 0)) % A single frame that has no line data
    CurrentEvents = PhotonArray;
    MaxPhotonTime = CurrentEvents(end,1);
    TimeForYLine = ceil(MaxPhotonTime / SizeY);
    m = 1;
    for n = 1:SizeY
       while ((CurrentEvents(m,1) <= TimeForYLine * n) && (m < TotalEvents))
          CurrentEvents(m,2) = TimeForYLine * (n - 1);
          m = m + 1;
       end
    end
    
    %% Substract line start times from photon arrival times
    CurrentEvents(:,1) = CurrentEvents(:,1) - CurrentEvents(:,2);
    
    %% Create edge vectors
    EdgeY = (unique(CurrentEvents(:,2)))';
    EdgeY = EdgeY(1,2:end); % Otherwise it takes 0 as its first value
    EdgeX = linspace(0, TimeForYLine, SizeX);
   
    %% Run hist3
    RawImagesMat(:,:,CurrentFrameNum) = PhotonSpreadToImage2(CurrentEvents, SizeX, SizeY, EdgeX, EdgeY);
    imagesc(RawImagesMat(:,:,CurrentFrameNum))
else
    for CurrentFrameNum = 1:max(1, size(StartOfFrameVec, 1) - 1) % If a frame isn't complete an image won't be generated from it

        %% Take relevant data
        if ~isempty(StartOfFrameVec)
            CurrentEvents = PhotonArray((PhotonArray(:,2) >= StartOfFrameVec(CurrentFrameNum, 1) & (PhotonArray(:,2) < StartOfFrameVec(CurrentFrameNum + 1, 1))),:); % Only photons that came in the specific time interval of the CurrentFrameNum's frame
        else
            CurrentEvents = PhotonArray;
        end
        
        %% Check if we have TAG phase data and calculate edge vector of image (for hist3 function)
 
        % X is responsible for TAG\line data
        if MaxDiffOfLines ~= 0
            EdgeX = linspace(0, MaxDiffOfLines, SizeX); 
        elseif isempty(MaxDiffOfLines)
            continue;
        else
            EdgeX = linspace(0, CurrentEvents(1,2), SizeX);
        end  

        if size(PhotonArray, 2) < 3
            TAGPhaseUse = 0;
            EdgeY = linspace(CurrentEvents(1,2), CurrentEvents(end,2), SizeY);
        else
            CurrentEvents(:, 3) = abs(sin(CurrentEvents(:, 3)));
            TAGPhaseUse = 1;
            finiteEvents = CurrentEvents(isfinite(CurrentEvents(:,3)), :);
            CurrentEvents = finiteEvents; % We throw out all photons without TAG phase
            sumOfEvents = CurrentEvents(:,1) + CurrentEvents(:,2);
            CurrentEvents(:,1) = sumOfEvents; 
           
            %% 
            EdgeX = linspace(0, 1, SizeX);
            EdgeY = linspace(min(CurrentEvents(:,1)), max(CurrentEvents(:,1)), SizeY);
            %%
            RawImagesMat(:,:,CurrentFrameNum) = PhotonSpreadToImage2(CurrentEvents(:,[1 3]), EdgeY, EdgeX);
        end

        %% Run hist3
        if ~TAGPhaseUse
            RawImagesMat(:,:,CurrentFrameNum) = PhotonSpreadToImage2(CurrentEvents(:,1:2), EdgeX, EdgeY);
            oddLines = RawImagesMat(1:2:end, :, CurrentFrameNum);
            oddLines = fliplr(oddLines);
            RawImagesMat(1:2:end,:,CurrentFrameNum) = oddLines;
        end
        
        %% Flip the frames of image
        if mod(CurrentFrameNum, 2) == 0
            RawImagesMat(:,:,CurrentFrameNuM) = flipud(RawImagesMat(:,:,CurrentFrameNum));
         
        end
        
        %% Show image
        imagesc(RawImagesMat(:,:,CurrentFrameNum))
    end
end

end
