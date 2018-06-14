function writegeotiff(raster,filename);
% writegeotiff - write 


filename=fixextension(filename,'.tif');
load globalarray2geotiff_5minR.mat

rasterforwriting=permute(raster,[2 1 3]);

geotiffwrite(filename,rasterforwriting,R);