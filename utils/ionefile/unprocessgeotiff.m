function unprocessgeotiff(raster,R,filename);
% unprocessgeotiff - save raster into GLI standard format to geotiffformat
%  [long,lat,raster,R,info]=processgeotiff(filename);
%


A=permute(raster,[2,1,3]);  % this unpermutes

geotiffwrite(filename,A,R);
