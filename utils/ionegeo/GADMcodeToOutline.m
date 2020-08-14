function ii=GADMcodeToOutline(ISO3);
% GADMcodeToOutline - replace a GADM code with outline, use GADM 
%

persistent gadm0codes raster0

if isempty(raster0)
    load /ionedata/AdminBoundary2020/gadm36_level0raster5minVer0.mat
end


idx=strmatch(ISO3,gadm0codes);
ii=raster0==idx;
