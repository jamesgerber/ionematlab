function globalarray2geotiff(raster,filename, varargin)
% globalarray2geotiff - converts a raster into a geotiff file  
% 
% If the longitude latitude arrays are not inputted (varargs)
% Raster must be a raster of the earth
%
%
%
%

% Written by Sam Stiffman
% Last Edited 1/7/2019

DEFAULT_SIZE = [4320 2160];
FIVE_MINUTE_RESOLUTION = 1/12; 

rows = size(raster, 1);
columns = size(raster, 2);
rasterSize = [rows, columns];

if nargin == 2
 
 % We can see which is bigger the raster or 5 minute model We can also see
 % if they are multiples since mod(a,b)==0 => b|a
 rasterMod5Minutes = mod(rasterSize, DEFAULT_SIZE);
 fiveMinutesModRaster = mod(DEFAULT_SIZE, rasterSize);

 if isequal(rasterSize, DEFAULT_SIZE)
    scalingFactor = 1;
    
 %Check if they are multiples    
 elseif ~rasterMod5Minutes
    scalingFactor = rasterSize ./ DEFAULT_SIZE;
    scalingFactor = scalingFactor(1);
 elseif ~fiveMinutesModRaster
    scalingFactor = DEFAULT_SIZE ./ rasterSize;
    scalingFactor = scalingFactor(1);
 else
    error('MATLAB:arguments:InconsistentDataType', ['Raster must have dimensions that are an integer multiple of [4320 2160] current dimensions: ' num2str(rasterSize)]);
 end

 %Define a new object R
 
 
 R.RasterSize = rasterSize;
 R.CellExtentInLatitude = FIVE_MINUTE_RESOLUTION * scalingFactor;
 R.CellExtentInLongitude = FIVE_MINUTE_RESOLUTION * scalingFactor;
 
elseif nargin == 4
 longitude = cell2mat(varargin(1));
 latitude = cell2mat(varargin(2));
 %Calculate resolution
 longResolution = (longitude(end) - longitude(1))/size(raster, 1);
 latResolution = (latitude(end) - latitude(1))/size(raster, 2);
 
 %Define R
 load globalarray2geotiff_5minR.mat R;
 R.RasterSize = rasterSize;
 R.CellExtentInLatitude =  longResolution;
 R.CellExtentInLongitude = latResolution;
 R.LongitudeLimits = [longitude(1) longitude(end)];
 R.LatitudeLimits = [latitude(1) latitude(end)];
end


filename=fixextension(filename,'.tif');


rasterforwriting=permute(raster,[2 1 3]);

geotiffwrite(filename,rasterforwriting,R);