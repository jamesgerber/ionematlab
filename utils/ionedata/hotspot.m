function [Hotspot,Tradeoff]=hotspot(area,goodthingperha,badthingperha,percentage);
% HotSpot - determine hotspots in a dataset
%
%   HOTSPOT determines which points are most associated with some undesired
%   characteristic.   It works in two ways:  it determines hotspots, which
%   speak to the locations with the greatest 'bad thing' and it determines
%   tradeoffs, which speak to the locations which provide 'good thing' at
%   the biggest cost in 'bad thing'
%
%
%   Syntax
%
%       [Hotspot,Tradeoff]=hotspot(area,goodthingperha,badthingperha,N)
%
%       TradeOff is a structure which contains fields
%         .RB   % relative badness, in other words, 100*N% of goodthing
%               % results in 100*RB% of badthing 
%         .ii   % indices of the set points which produce N% of goodthing          
%               % at the maximum cost (RB%) of badthing
%         .iigoodDQ  %indices of input vectors that passed data quality
%         checks (i.e. not NAN, or 9E9, or 0 area)
%       To do a hotspot calculation to analyze badthing per area, use '1'
%       for goodthingperha
%
%      Three likely uses for this code in terms of desired outputs
%         "25% of land contains 40% of excess N"    (tradeoff)
%         "25% of yield is associated with 36% of excess N"  (tradeoff)
%         "25% of excess N is found on 17% of land"  (hotspot)
%
%
%  Example
%
%       S=OpenNetCDF([iddstring '/Fertilizer2000/maizeNapprate']);
%       Napp_per_ha=S.Data(:,:,1);
%       S=getdata('maize');
%       area=S.Data(:,:,1);
%       yield=S.Data(:,:,2);
%       ii=CountryCodetoOutline('USA');
%       [RB]=hotspot(area(ii).*fma(ii),1,Napp_per_ha(ii),20);
%       disp([ int2str(RB*100) '% of N goes on 20% of maize crop area in US']);
%       [RB]=hotspot(area(ii).*fma(ii),yield(ii),Napp_per_ha(ii),20);
%       disp([ int2str(RB*100) '% of N goes on 20% of maize produced in US']);
%
%       ii=LandMaskLogical;
%       [RB]=hotspot(area(ii).*fma(ii),1,Napp_per_ha(ii),20);
%       disp([ int2str(RB*100) '% of N goes on 20% of maize crop area in world']);
%       [RB]=hotspot(area(ii).*fma(ii),yield(ii),Napp_per_ha(ii),20);
%       disp([ int2str(RB*100) '% of N goes on 20% of maize produced in world']);
%       
%
%    See Also:  justhotspot  justtradeoff

%    Here is the code I used to corroborate this against nature paper
%    results ...
%    [RB,areacutoff]=hotspot(croparea(ii).*fma(ii),ones(size(find(ii))),ExcessNitrogenPerHA_avg(ii),10)
%
%
%
if percentage > 1
    percentage=percentage/100;
end

if mean(area)<1
    warndlg('area very small ... that''s probably fractional grid area, not area in ha')
end

if goodthingperha==1
    goodthingperha=ones(size(area));
end

%% data quality check

%iigood=(badthingperha > 0 ) & (~isnan(goodthingperha.*badthingperha.*area)) & ...
%    area > 0 & area < 9e5;

iigood= (~isnan(goodthingperha.*badthingperha.*area)) & ...
    area > 0 & area < 9e5;

if any(badthingperha(iigood)<0)
    warndlg([' Some of the bad thing is negative.  Sums will cancel out,' ...
        ' possibly leading to an overestimate of intensity of hotspots '])
end

area=area(iigood);
goodthingperha=goodthingperha(iigood);
badthingperha=badthingperha(iigood);

if isempty(find(iigood))
    RelativeBadness=-1;
    TradeOff.RB=RelativeBadness;
    TradeOff.ii=[];
    TradeOff.iigood=iigood;    
    
    RelativeGoodness=-1;
    HotSpot.RG=RelativeGoodness;
    HotSpot.ii=[];
    HotSpot.iigoodDQ=iigood;
    return
end

%% TradeOff - how much bad to get the amount of good?

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

Cutoff=badquantity(jj);

TotalBadness=sum(badsort);
PartialBadness=sum(badsort(1:jj));

RelativeBadness=PartialBadness/TotalBadness;

TradeOff.RB=RelativeBadness;
TradeOff.ii=iigood(ii(1:jj));  
TradeOff.iigoodDQ=iigood;


%% HotSpot - how much good is associated with this amount of bad?

cumbad=cumsum(badsort);
cumbad=cumbad/max(cumbad);

[dum,kk]=min( (cumbad-percentage).^2);

Cutoff=badquantity(kk);
TotalGoodness=sum(badsort);
PartialGoodness=sum(badsort(1:kk));

RelativeGoodness=PartialGoodness/TotalGoodness;

HotSpot.RG=RelativeGoodness;
HotSpot.ii=iigood(ii(1:kk));  
HotSpot.iigoodDQ=iigood;



