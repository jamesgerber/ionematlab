function [g0]=getgeo41(ISO);
% getgeo41 get harmonized geo data from GADM4.1
%
%   [g0,g1,g2,g3,g]=getgeo41;




persistent savethings

if isempty(savethings)
    g0=load('/Users/jsgerber/DataProducts/ext/GADM/GADM41/gadm41_level0raster5minVer2.mat');

    g0.raster0lml=g0.raster0(landmasklogical);

    savethings.g0=g0;

else
    
    g0=savethings.g0;

end



if nargin==1

    idx=strmatch(ISO,g0.gadm0codes);
    g0=subsetofstructureofvectors(g0,idx);

 

end

