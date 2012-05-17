function [iilong,jjlat]=latlongindices(data,site);
% LATLONGINDICES - Long/Lat range for a given country


[Nlong,Nlat]=size(data);

long=linspace(-180,180,Nlong);
lat=linspace(90,-90,Nlat);

switch lower(site(1:2))
 case {'us','am'}
  iilong=find(long > -125 & long < -60);
  jjlat=find(lat > 25 & lat < 50);
  
 otherwise
  error('don''t have that region')
end
