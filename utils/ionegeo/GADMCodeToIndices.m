function [ii,name]=GADMCodeToIndices(GADMCode)
% GADMCodeToIndices


[g0,g1,g2,g3,g]=getgeo41;


idx=strmatch(GADMCode,g0.gadm0codes,'exact');
if numel(idx)==1
    ii=find(g0.raster0==idx);
    name=g0.namelist0{idx};
    return
end

idx=strmatch(GADMCode,g1.gadm1codes,'exact');
if numel(idx)==1
    ii=find(g1.raster1==idx);
    name=g1.namelist1{idx};
    return
end


idx=strmatch(GADMCode,g2.gadm2codes,'exact');
if numel(idx)==1
    ii=find(g2.raster2==idx);
    name=g2.namelist2{idx};
    return
end


idx=strmatch(GADMCode,g3.gadm3codes,'exact');
if numel(idx)==1
    ii=find(g3.raster3==idx);
    name=g3.namelist3{idx};
    return
end

keyboard