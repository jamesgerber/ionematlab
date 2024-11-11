function [CPD,verstring]=ReturnCropProductionData;
% ReturnCropProductionData - FAOstat production data, limit to crops

[c,verstring]=ReturnProductionData;

if ~isequal(verstring,'Oct_2024')
    error(' you have updated FAO productiond data. confirm that the item_codes hardwired here haven''t changed')
end

iianimal=c.Item_Code >865 & c.Item_Code <=1225 | ...
    c.Item_Code >1805 & c.Item_Code <1816 | ...
    c.Item_Code==2029;

 c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),find(iianimal)));


% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Laying',c.Element)));
% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Milk Animals',c.Element)));
% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Laying',c.Element)));
% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Prod Popultn',c.Element)));
% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Producing Animals/Slaughtered',c.Element)));
% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Stocks',c.Element)));
% c=subsetofstructureofvectors(c,setdiff(1:numel(c.Unit),strmatch('Yield/Carcass Weight',c.Element)));


CPD=c;

