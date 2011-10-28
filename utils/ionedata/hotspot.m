function [RelativeBadness,Cutoff]=hotspot(area,goodthingperha,badthingperha,percentage);
% HotSpot - determine hotspots in a dataset
%
%   Syntax
%
%       [RB]=hotspot(area,goodthingperha,badthingperha,N)
%       
%       100*N% of goodthing results in 100*RB% of badthing
if percentage > 1
    percentage=percentage/100;
end

%% data quality check

iigood=(badthingperha > 0 ) & (~isnan(goodthingperha.*badthingperha.*area));

area=area(iigood);
goodthingperha=goodthingperha(iigood);
badthingperha=badthingperha(iigood);

if isempty(find(iigood))
    RelativeBadness=-1;
    Cutoff=NaN;
    return
end


% we sort by 'bad thing' rates
[dum,ii]=sort(badthingperha,'descend');

% after sorting by rates, though, we don't want rates, we want rates*area
badquantity=badthingperha.*area;
goodquantity=goodthingperha.*area;

goodsort=goodquantity(ii);
badsort=badquantity(ii);

cumgood=cumsum(goodsort);
cumgood=cumgood/max(cumgood);

[dum,jj]=min( (cumgood-percentage).^2);

cutoff=badquantity(jj);

TotalBadness=sum(badsort);
PartialBadness=sum(badsort(1:jj));

RelativeBadness=PartialBadness/TotalBadness;




