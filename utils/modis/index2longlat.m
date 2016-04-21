function [long,lat]=index2longlat(index,Nskip);

if nargin==1
    Nskip=1;
end


[DeltaLon,LonLims,LonVect,DeltaLat,LatLims,LatVect,FrameRasterSize]=modisrasterconstants(Nskip);


[i,j]=ind2sub(FrameRasterSize,index);

long=LonVect(i)
lat=LatVect(j)