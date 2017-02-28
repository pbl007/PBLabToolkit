function adjacentBlockPairList = MosaicTiling_buildBlockAdjacency(mosaicLayout)

task = 'Building Block adjacency matrix';
fprintf('\n%s',repmat('*',60,1));
fprintf('\n%s',task);
t0 = clock;
%initilize adjacency
numBlocks = mosaicLayout.numBlocks;
Adj = sparse(numBlocks,numBlocks);

%extract block ids and embbed in zero-padded matrix
blockInLayoutRCZ = mosaicLayout.blockInLayoutRCZ;
tmp = zeros(numBlocks+2,numBlocks+2);
idx = sub2ind(size(tmp),blockInLayoutRCZ(:,1)+1,blockInLayoutRCZ(:,2)+1);
tmp(idx) = 1:numBlocks;
blockIds = tmp; clear tmp

%define sampling kernel
Srcz = [0 1 0;1 0 1;0 1 0]; % 4-adjacency



blockR = blockInLayoutRCZ(:,1) + 1;
blockC = blockInLayoutRCZ(:,2) + 1;
% blockZ = prmts.blockZ + 1;% not supporting 3D layout for now

sizeAdj = size(Adj);
for bi = 1 : numBlocks
    tmp = blockIds((-1 : 1) + blockR(bi),(-1 : 1) + blockC(bi));
    tmp = tmp .* Srcz;
    neighs = tmp(tmp>0);
    n = numel(neighs);
    idx = sub2ind(sizeAdj,repmat(bi,n,1),neighs);
Adj(idx) = 1; %connect
end %cycling blocks
[p1 p2] = find(triu(max(Adj,Adj')));
adjacentBlockPairList = [p1 p2];
fprintf('\nFinished %s in %6.2f sec',task,etime(clock,t0));
fprintf('\n%s\n',repmat('*',60,1));