function correctRaster = Felipe(raster)
% Felipe - takes a raster of the earth in 4320x2160 so it is output to
% thinsurf correctly
% 
%
% Examples:  
%
% x = landmasklogical
% xbad1 = flip(x)     %%% Upside down map
% xbad2 = fliplr(x)   %%% Flipped Map
% xbad3 = flip(xbad2) %%% Map that is flipped and upsidedown
% thinsurf(Felipe(x))
% thinsurf(Felipe(xbad1))
% thinsurf(Felipe(xbad2))
% thinsurf(Felipe(xbad3))
%

rasterSize = size(raster);
resolution = detectResolution(raster);
oneDegreeSize = rasterSize * resolution;
%Raster must be a raster of the earth 
assert(isequal(oneDegreeSize, [360 180]) || isequal(oneDegreeSize, [180 360]));

%if its up or down flip it sideways
if rasterSize(2) > rasterSize(1)
    raster = raster'; 
end

%See what value water is in the map since long lat 0,0 is always water 
waterValue = raster(end/2, end/2);
% make water 0
if waterValue ~= 0
    indexesOfWater = raster == waterValue;
    tempRaster = raster .* ~indexesOfWater;
else
    tempRaster=raster;
end

% To figure out what orientation match the map with a logical earth map at
% each orientation and see which one matches best
correctLogical = ~landmasklogical;

% If resolution is not the same as the landmask logical needs to be scaled
if resolution ~= 5/60
    imresize(correctLogical, resolution/(5/60));
end
    upsideDown = fliplr(correctLogical);
    flippedUpsidedown = flip(upsideDown);
    flippedNormal = flip(correctLogical);
    
    % Temporary matrices to see how many values are left
    % CO -> correct orientation, UD -> upsidedown, FCO -> Flipped CO map,
    % FUD -> flipped UD map 
    CO = tempRaster .* correctLogical;
    UD = tempRaster .* upsideDown;
    FCO = tempRaster .* flippedNormal;
    FUD = tempRaster .* flippedUpsidedown;
    % S prefix is a sum of all non-0 values
    SCO = sum(sum(CO .* (CO > 0)));
    SUD = sum(sum(UD .* (UD > 0)));
    SFCO = sum(sum(FCO .* (FCO > 0)));
    SFUD = sum(sum(FUD .* (FUD > 0)));
    
    arrayOfSums = [SCO SUD SFCO SFUD];
   
    if min(arrayOfSums) == SCO
        % Map is correct orientation no need for an operation
        correctRaster = raster; 
    elseif min(arrayOfSums) == SUD
        correctRaster = fliplr(raster);
    elseif min(arrayOfSums) == SFCO
        correctRaster = flip(raster);
    elseif min(arrayOfSums) == SFUD
        correctRaster = flip(fliplr(raster));
    else
        error('MATLAB:arguments:InconsistentDataType', 'Raster not map of Earth');
    end
end

function resolution = detectResolution(raster)

rasterSize = size(raster);
FiveMinuteResolution = [2160 4320];
flippedFiveMinuteResolution = [4320 2160]; 

% Correct orientation of the earth
if rasterSize(2) > rasterSize(1)
    rasterMod5Minutes = mod(rasterSize, FiveMinuteResolution);
    fiveMinutesModRaster = mod(FiveMinuteResolution, rasterSize);
    
    %Check if they are multiples
    if ~rasterMod5Minutes
        scalingFactor = rasterSize ./ FiveMinuteResolution;
        scalingFactor = scalingFactor(1);
    elseif ~fiveMinutesModRaster
        scalingFactor = FiveMinuteResolution ./ rasterSize;
        scalingFactor = scalingFactor(1);
    else
        error('MATLAB:arguments:InconsistentDataType', ['Raster must have dimensions that are an integer multiple of [2160 4320] current dimensions: ' num2str(rasterSize)]);
    end
% Incorrect orientation of the earth
elseif rasterSize(1) > rasterSize(2)
    
    rasterMod5Minutes = mod(rasterSize, flippedFiveMinuteResolution);
    fiveMinutesModRaster = mod(flippedFiveMinuteResolution, rasterSize);
    
    if ~rasterMod5Minutes
        scalingFactor = rasterSize ./ flippedFiveMinuteResolution;
        scalingFactor = scalingFactor(1);
    elseif ~fiveMinutesModRaster
        scalingFactor = flippedFiveMinuteResolution ./ rasterSize;
        scalingFactor = scalingFactor(1);
    else
        error('MATLAB:arguments:InconsistentDataType', ['Raster must have dimensions that are an integer multiple of [2160 4320] current dimensions: ' num2str(rasterSize)]);
    end
else
    error('MATLAB:arguments:InconsistentDataType', 'Raster not map of Earth');
end    

resolution = (5/60)*scalingFactor;
end


