function S = getfertdata(cropname,nutrient)

% S = getfertdata(cropname,nutrient)
%
% a function to return fertilizer information from the IonE data directory
% 
% nutrient should be N, P, or K: data returned will be in units of N, P2O5,
% or K2O

outputpath = [iddstring '/Fertilizer2000/'];
switch nutrient
    case 'N'
        nutlabel = 'N';
    case 'P'
        nutlabel = 'P2O5';
    case 'K'
        nutlabel = 'K2O';
end
datastr = [outputpath cropname nutlabel 'apprate.nc'];
S = OpenNetCDF(datastr);
