function [long,lat,raster,R,info]=processgeotiff(filename);
% processgeotiff - load geotiff, put into GLI standard format
%  [long,lat,raster,R,info]=processgeotiff(filename);
%
% %example
%
%filename='~/Downloads/imageToDriveExample.tif';
%[long,lat,raster,R,info]=processgeotiff(filename);
%
% see also aggregate_to_5min

[A,R]=geotiffread(filename);

%if isfield(R,'LongitudeLimits');
try
    
    LonLims=R.LongitudeLimits;
    LatLims=R.LatitudeLimits;
    DeltaLon=R.CellExtentInLongitude;
    DeltaLat=R.CellExtentInLatitude;
    
catch
    LonLims=R.XWorldLimits;
    LatLims=R.YWorldLimits;
    DeltaLon=R.CellExtentInWorldX;
    DeltaLat=R.CellExtentInWorldY;
    
    
end
%diff(LonLims)/size(A,2)


% define long, lat vector.  trick with extra element in the linspace
% command, then take it away is is so that we are consistent with where we
% are relative to the pixel center
long=linspace(LonLims(1)+DeltaLon/2,LonLims(2)-DeltaLon/2,size(A,2));
lat=linspace(LatLims(1)+DeltaLat/2,LatLims(2)-DeltaLon/2,size(A,1));

if isequal(R.ColumnsStartFrom,'north');
    lat=lat(end:-1:1);  % need to reverse lat.  i sure hope this doesn't break things.
end

%raster=A';
raster=permute(A,[2,1,3]);
R=R;


if nargout==5
    info=geotiffinfo(filename);
end
