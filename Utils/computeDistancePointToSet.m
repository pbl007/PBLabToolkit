function d = computeDistancePointToSet(pointSet,point)
%compute the distance between a point p to all points in set 

point = repmat(point,size(pointSet,1),1);
d = sqrt(sum((pointSet-point).^2,2));