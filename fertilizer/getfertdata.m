function [S,existflag] = getfertdata(cropname,nutrient)

% [S,existflag] = getfertdata(cropname,nutrient)
%
% a function to return fertilizer information from the IonE data directory
%
% nutrient should be N, P, or K: data returned will be in units of N, P2O5,
% or K2O
%
% to get total consumption data, use cropname = 'totalcons'
%
% exist flag is a binary indicator (1 or 0) indicating whether data was
% returned for this crop-nutrient combination in structure S.

outputpath = [iddstring 'Fertilizer2000/'];
switch nutrient
    case 'N'
        nutlabel = 'N';
    case 'P'
        nutlabel = 'P2O5';
    case 'K'
        nutlabel = 'K2O';
end
if strmatch(cropname,'totalcons')
    datastr =[outputpath nutlabel cropname '.nc'];
else
    datastr = [outputpath cropname nutlabel 'apprate.nc'];
end

% check if the file exists - if so, open it
tmp = exist(datastr) + exist([datastr '.gz']);
if tmp > 1
    S = OpenNetCDF(datastr);
    existflag = 1;
else
    warning(['No ' cropname ' ' nutlabel ' fertilizer file found.']);
    S = 0;
    existflag = 0;
end