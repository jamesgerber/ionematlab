function globalarray2geotiff(raster,filename, varargin)
% globalarray2geotiff - converts a raster into a geotiff file  
% 
% If the longitude latitude arrays are not inputted (varargs)
% Raster must be a raster of the earth
%

rows = size(raster, 1);
columns = size(raster, 2);
rasterSize = [rows, columns];
defaultSize = [2160 4320];
if nargin == 2
 
 %So we can see which is bigger raster or 5minute model also so we can see
 %if they are multiples since mod(a,b)==0 => b|a
 rasterMod5Minutes = mod(rasterSize, defaultSize);
 fiveMinutesModRaster = mod(defaultSize, rasterSize);

 if isequal(rasterSize, defaultSize)
    scalingFactor = 1;
 %Check if they are multiples    
 elseif ~rasterMod5Minutes
    scalingFactor = rasterSize ./ defaultSize;
    scalingFactor = scalingFactor(1);
 elseif ~fiveMinutesModRaster
    scalingFactor = defaultSize ./ rasterSize;
    scalingFactor = scalingFactor(1);
 else
    error('MATLAB:arguments:InconsistentDataType', ['Raster must have dimensions that are an integer multiple of [2160 4320] current dimensions: ' num2str(rasterSize)]);
 end

 %Define R
 load globalarray2geotiff_5minR.mat;
 R.RasterSize = defaultSize * scalingFactor;
 R.CellExtentInLatitude = (1/12) * scalingFactor;
 R.CellExtentInLongitude = (1/12) * scalingFactor;
 
elseif nargin == 4
 longitude = varargin(1);
 latitude = varargin(2);
 %Calculate resolution
 longResolution = (longitude(end) - longitude(1))/size(raster, 1);
 latResolution = (latitude(end) - latitude(1))/size(raster, 2);
 
 %Define R
 load globalarray2geotiff_5minR.mat;
 R.RasterSize = rasterSize;
 R.CellExtentInLatitude =  longResolution;
 R.CellExtentInLongitude = latResolution;
 R.LongitudeLimits = [longitude(1) longitude(end)];
 R.LatitudeLimits = [latitude(1) latitude(end)];
end


filename=fixextension(filename,'.tif');


rasterforwriting=permute(raster,[2 1 3]);

geotiffwrite(filename,rasterforwriting,R);