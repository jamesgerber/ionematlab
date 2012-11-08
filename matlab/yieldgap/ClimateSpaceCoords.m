function [Xval,Yval]=ClimateSpaceCoords(Lat,Long,Xmatrix,Ymatrix);
% ClimateSpaceCoords
%
%  Syntax:
%      [Xval,Yval]=ClimateSpaceCoords(Long,Lat,Xmatrix,Ymatrix);
%      [Xval,Yval]=ClimateSpaceCoords(Long,Lat,GDD,TMI);


[LongVect,LatVect]=InferLongLat(Xmatrix);

% X
Xval=interp2(LongVect,LatVect,Xmatrix.',Long,Lat);
Yval=interp2(LongVect,LatVect,Ymatrix.',Long,Lat);
