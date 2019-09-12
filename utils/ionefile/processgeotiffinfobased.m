function [long,lat,raster,R,info]=processgeotiffinfobased(filename,longlatfilename);
% processgeotiffinfobased - load geotiff, put into GLI standard format
%  [long,lat,raster,R,info]=processgeotiffinfobased(filename,longlatfilename);
%
% %example
%
%filename='~/Downloads/imageToDriveExample.tif';
%[long,lat,raster,R,info]=processgeotiffinfobased(filename,longlatfilename);


info=geotiffinfo(filename);

[A]=geotiffread(filename);
a=A';


% let's make lon/lat so del has to be positive. then goes from min to max
dellon=abs((info.CornerCoords.Lon(2)-info.CornerCoords.Lon(1))/size(a,1));
dellat=abs((info.CornerCoords.Lat(4)-info.CornerCoords.Lat(1))/size(a,2));

long=(min(info.CornerCoords.Lon)+dellon/2):dellon:max(info.CornerCoords.Lon);
lat=(min(info.CornerCoords.Lat)+dellat/2):dellat:max(info.CornerCoords.Lat);


%[a,R]=geotiffread(longlatfilename);




if ~isequal(size(a),size(A))
    error([' failed test on sizes the same in ' mfilename]);
end
raster=permute(A,[2,1,3]);
R=R;


LonLims=R.LongitudeLimits;
LatLims=R.LatitudeLimits;
DeltaLon=R.CellExtentInLongitude
DeltaLat=R.CellExtentInLatitude;
%diff(LonLims)/size(A,2)


% define long, lat vector.  trick with extra element in the linspace
% command, then take it away is is so that we are consistent with where we
% are relative to the pixel center
long=linspace(LonLims(1),LonLims(2),size(A,2)+1);
lat=linspace(LatLims(1),LatLims(2),size(A,1)+1);
long=long(1:end-1);
lat=lat(1:end-1);

lat=lat(end:-1:1);  % need to reverse lat.  i sure hope this doesn't break things.

%raster=A';
raster=permute(A,[2,1,3]);
R=R;


if nargout==5
    info=geotiffinfo(filename);
end


