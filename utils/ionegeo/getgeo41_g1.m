function [g1,ii,countryname,statename]=getgeo41_g1(ISO);
% getgeo41 get harmonized geo data from GADM4.1
%
%  [g1]=getgeo41_g1;
%  [g1]=getgeo41_g1(ISO);
%  [g1,ii,countryname,statename]=getgeo41_g1(ISO);  % this syntax returns a list of
%  all states within ISO




persistent savethings

if isempty(savethings)
    g1=load('/Users/jsgerber/DataProducts/ext/GADM/GADM41/gadm41_level1raster5minVer2.mat');

    g1.raster1lml=g1.raster1(landmasklogical);

    savethings.g1=g1;

else
    
    g1=savethings.g1;

end



if nargin==1
    idx=strmatch(ISO,g1.gadm0codes);
    g1=subsetofstructureofvectors(g1,idx);
end

if nargout>=2 
    if nargin==1
        for m=1:numel(g1.namelist1);
        ii{m}=find(g1.raster1==g1.uniqueadminunitcode(m));
        countryname{m}=g1.countrynames{m};
        statename{m}=g1.namelist1{m};
        end
    else
        error
    end
end
