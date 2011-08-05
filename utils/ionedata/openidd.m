function A=openidd(s)
if isempty(strfind(s,'/'))
    s=['Crops2000/Crop/' s];
end
A=opennetcdf([iddstring s]);