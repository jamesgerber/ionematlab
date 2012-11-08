function S = getmanuredata(cropname,nutrient)

% S = getmanuredata(cropname,nutrient)
%
% a function to return fertilizer information from the IonE data directory
%
% nutrient should be N or K: data returned will be in units of N, P2O5,
% or K2O
%
% exist flag is a binary indicator (1 or 0) indicating whether data was
% returned for this crop-nutrient combination in structure S.

outputpath = [iddstring 'misc/CropSpecificManureAdditions/'];
switch nutrient
    case 'N'
        nutword = 'Nitrogen';
    case 'P'
        nutword = 'Phosphorus';
end

datastr = [outputpath nutword 'FromManure' cropname '.nc'];

S = OpenNetCDF(datastr);
