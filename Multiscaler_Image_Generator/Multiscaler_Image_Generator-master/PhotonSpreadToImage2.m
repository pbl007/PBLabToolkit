function [RawImage] = PhotonSpreadToImage2(CurrentEvents, EdgeX, EdgeY)

%% Building a histogram of photon locations
Edges = {EdgeX EdgeY};
RawImage = hist3(CurrentEvents, 'Edges', Edges);

end