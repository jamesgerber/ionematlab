function [DeltaLon,LonLims,LonVect,DeltaLat,LatLims,LatVect,FrameRasterSize]=modisrasterconstants(Nskip);

% hardwire the raster we'll work on when analyzing modis data


if nargin==0
    Nskip=1;
end


% constants from Modis tiles
DeltaLat=0.00212982254478162;
LatLims=[-33.7470817565918 5.2648777961731] + DeltaLat*[-10 10];

DeltaLon= 0.00212987794941342;
LonLims=[-73.9897079467773 -34.7956939216716]+DeltaLon*[-20 20];


LatVect=LatLims(1):DeltaLat:(LatLims(end)+DeltaLat/1e5); % add on a little bit to catch round-off error
LonVect=LonLims(1):DeltaLon:(LonLims(end)+DeltaLon/1e5);

LatVect=LatVect(1:Nskip:end);
LonVect=LonVect(1:Nskip:end);

LatLims=[LatVect(1) LatVect(end)];
LonLims=[LonVect(1) LonVect(end)];


FrameRasterSize=[length(LonVect) length(LatVect)];
