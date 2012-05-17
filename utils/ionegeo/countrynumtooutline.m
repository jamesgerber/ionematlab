function [iiRegion,RegionName]=countrynumtooutline(j);
% countrynumtooutline - turn a sage country number to an outline & name
%
% Syntax
%        [iiRegion,RegionName]=countrynumtooutline(5);
%
%
persistent IndicesWithSageNames NS
if isempty(IndicesWithSageNames)
    NS=standardcountrynames;
    ii=strmatch('',NS.Sage3,'exact');
    k=ones(size(NS.Sage3));
    k(ii)=0;
    IndicesWithSageNames=find(k);
end

idx=IndicesWithSageNames(j);

iiRegion=countrycodetooutline(NS.Sage3(idx));
RegionName=char(NS.SageCountryNoComma(idx));
  

