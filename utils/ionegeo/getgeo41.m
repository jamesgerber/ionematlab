function [g0,g1,g2,g3,g]=getgeo41(ISO);
% getgeo41 get harmonized geo data from GADM4.1
%
%   [g0,g1,g2,g3,g]=getgeo41;




persistent savethings

if isempty(savethings)
    g0=load('/Users/jsgerber/DataProducts/ext/GADM/GADM41/gadm41_level0raster5minVer2.mat');
    g1=load('/Users/jsgerber/DataProducts/ext/GADM/GADM41/gadm41_level1raster5minVer2.mat');
    g2=load('/Users/jsgerber/DataProducts/ext/GADM/GADM41/gadm41_level2raster5minVer2.mat');
    g3=load('/Users/jsgerber/DataProducts/ext/GADM/GADM41/gadm41_level3raster5minVer2.mat');


    g0.raster0lml=g0.raster0(landmasklogical);
    g1.raster1lml=g1.raster1(landmasklogical);
    g2.raster2lml=g2.raster2(landmasklogical);
    g3.raster3lml=g3.raster3(landmasklogical);

    g3=rmfield(g3,'countrynames2');
    g3=rmfield(g3,'uniqueadminunitcode2');

    for j=1:numel(g1.namelist1)
        g1.namecodes1{j}=[g1.countrynames{j} ' ' g1.namelist1{j}];
    end


    for j=1:numel(g2.namelist2)
        g2.namecodes2{j}=[g2.namelist0{j} ' ' g2.namelist1{j} ' ' g2.namelist2{j}];
    end



    % ghana fix

    ii=strmatch('GHA',g1.gadm0codes);
    for m=1:numel(ii);
        tmp=g1.gadm1codes{ii(m)};
        g1.gadm1codes{ii(m)}=[tmp(1:3) '.' tmp(4:end)];
    end
    for m=1:numel(g1.gadm1codes)
        g1.gadm1codes_with_subscript_1{m}=strrep(g1.gadm1codes{m},'_2','_1');
    end

    savethings.g0=g0;
    savethings.g1=g1;
    savethings.g2=g2;
        g3.uniqueadminunitcode3=g3.uniqueadminunitcode;

    savethings.g3=g3;
else
    
    g0=savethings.g0;
    g1=savethings.g1;
    g2=savethings.g2;
    g3=savethings.g3;
    g3.uniqueadminunitcode3=g3.uniqueadminunitcode;
end



if nargin==1

    idx=strmatch(ISO,g0.gadm0codes);
    g0=subsetofstructureofvectors(g0,idx);

    idx=strmatch(ISO,g1.gadm0codes);
    g1=subsetofstructureofvectors(g1,idx);

    idx=strmatch(ISO,g2.gadm0codes);
    g2=subsetofstructureofvectors(g2,idx);


    idx=strmatch(ISO,g3.gadm0codes);
    g3=subsetofstructureofvectors(g3,idx);


end

g=savethings;