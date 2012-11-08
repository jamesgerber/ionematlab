function [apprate] = getcropfertrate(cropname, nutrient, percentile, ...
    datamask)

% function [apprate] = getcropfertrate(cropname, nutrient, percentile, ...
%    datamask)
% 
% Determine application rate level that corresponds to the percentile
% specified. For example, you may want to know the 95th percentile nitrogen
% application on maize. This function will grab the appropriate data to
% make that calculation and return the application rate.
%
% Input a datamask if you want to calculate over a specific region.

if nargin < 4
    datamask = ones(4320,2160);
end

% make percentile a fraction if not already
if percentile > 1
    percentile = percentile ./ 100;
end
    
% get fertilizer data
DS = getfertdata(cropname, nutrient);
appratemap = DS.Data(:,:,1);

% get area data
DS = getdata(cropname);
areamap = DS.Data(:,:,1);
areamap(areamap > 10) = NaN;
areamap = areamap .* GetFiveMinGridCellAreas;

% identify grid cells to examine
ii = (datamask == 1) & isfinite(appratemap) & isfinite(areamap);

% sort and calculate the application rate
arealist = areamap(ii);
appratelist = appratemap(ii);

[sortedapprates,si] = sort(appratelist);
sortedapprates = appratelist(si);
sortedcroparea = arealist(si);
sortedcumcroparea = cumsum(sortedcroparea);
totcroparea = sum(sortedcroparea);
tmp = percentile .* totcroparea;
[dummyvalue,jj] = min(abs(sortedcumcroparea-tmp));

apprate = sortedapprates(jj);
