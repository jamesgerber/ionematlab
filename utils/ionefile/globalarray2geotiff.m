function filename=globalarray2geotiff(raster,filename)
% globalarray2geotiff - converts a raster into a geotiff file  
% 
%  globalarray2geotiff(raster,filename);
%
% If the longitude latitude arrays are not inputted (varargs)
% Raster must be a raster of the earth
%

% Written by Sam Stiffman
% Last Edited 7/8/2019

 latlim = [-90 90];
 lonlim = [-180 180];
 
 raster=raster(:,end:-1:1);
 
 R = georefcells(latlim,lonlim,size(raster'));



filename=fixextension(filename,'.tif');


rasterforwriting=raster';

geotiffwrite(filename,rasterforwriting,R);