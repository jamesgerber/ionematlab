function [long,lat,raster,R,info]=processgeotiff(filename,longlatfilename);
% processgeotiff - load geotiff, put into GLI standard format
%  [long,lat,raster,R,info]=processgeotiff(filename);
%
% %example
%
%filename='~/Downloads/imageToDriveExample.tif';
%[long,lat,raster,R,info]=processgeotiff(filename);

[A,R]=geotiffread(filename);
[a,r]=geotiffread(longlatfilename);
info=geotiffinfo(filename);

long=a(1,:,1);
lat=a(:,1,2);



if ~isequal(r,R)
    error([' failed the very stringent test on lat/long the same in ' mfilename]);
end
raster=permute(A,[2,1,3]);
R=R;
% % 
% % 
% % 
% % %% in theory, data is in the info structure.
% % 
% % 
% % LonLims=R.LongitudeLimits;
% % LatLims=R.LatitudeLimits;
% % DeltaLon=R.CellExtentInLongitude
% % DeltaLat=R.CellExtentInLatitude;
% % %diff(LonLims)/size(A,2)
% % 
% % 
% % % define long, lat vector.  trick with extra element in the linspace
% % % command, then take it away is is so that we are consistent with where we
% % % are relative to the pixel center
% % long=linspace(LonLims(1),LonLims(2),size(A,2)+1);
% % lat=linspace(LatLims(1),LatLims(2),size(A,1))+1;
% % long=long(1:end-1);
% % lat=lat(1:end-1);
% % 
% % %raster=A';
% % 



