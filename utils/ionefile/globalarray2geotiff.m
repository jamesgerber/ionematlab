function globalarray2geotiff(raster,filename);
% globalarray2geotiff - write a globe-spanning array to geotiff. 
%
% SYNTAX
%          globalarray2geotiff(raster,filename);
%
%

filename=fixextension(filename,'.tif');
load globalarray2geotiff_5minR.mat

rasterforwriting=permute(raster,[2 1 3]);

geotiffwrite(filename,rasterforwriting,R);