function [long,lat,raster,R]=processgeotiff(filename,latbox);

filename='pasture_data_2005.tif';

[A,R]=geotiffread('pasture_data_2005.tif');

if nargin==1
    latbox=[-180 180 -90 90];
end

