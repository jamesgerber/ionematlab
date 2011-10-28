function [RelativeBadness,Cutoff]=hotspot(area,goodthingperha,badthingperha,percentage);
% HotSpot - determine hotspots in a dataset
%
%   Syntax
%
%       [RB]=hotspot(area,goodthingperha,badthingperha,N)
%       
%       100*N% of goodthing results in 100*RB% of badthing
%
%       To do a hotspot calculation to analyze badthing per area, use '1'
%       for goodthingperha
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

iigood=(badthingperha > 0 ) & (~isnan(goodthingperha.*badthingperha.*area)) & ...
    area > 0 & area < 9e5;
%iigood= (~isnan(goodthingperha.*badthingperha.*area)) & ...
%    area > 0 & area < 9e5;

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

Cutoff=badquantity(jj);

TotalBadness=sum(badsort);
PartialBadness=sum(badsort(1:jj));

RelativeBadness=PartialBadness/TotalBadness;




