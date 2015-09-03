% can we get rainfall data for ramsey county for Jan 12, 3pm, 1922 from
% stripes and have it agree with data from map?
%
% vectorindex=84402
% Point Data:
% Country = Texas
% Lat = 31.0594
% Lon = -99.331
% ix=162
% iy=118


S=OpenGeneralNetCDF([iddstring 'Climate/reanalysis/WATCH/Tair_WFD/Tair_WFD_192201.nc']);

ls /ionedata/Climate/reanalysis/WATCH/
% which layer?

% first layer = Jan 1, 12
% second layer = Jan 1, 3am
% 9th layer = Jan 2

% (Nday-1)*8 +1+ (3hr intervals past midnight)
%
% 88 +1 = Jan 12, midnight
% 88+1+5 = Jan 12, 3pm

Nday=12
Hour=15

datalayer=S(6).Data(:,1+(Nday-1)*8+floor(Hour/3));


load('WFDindices','iivect') 

tair=datablank(0,'30min');
tair(iivect)=datalayer-273.15;

%nsg(tair)

tair(162,118)


[mdnvect,ts]=getstripe(84402,'Tair');
ts=ts-273.15;


mdn=datenum(1922,1,Nday,Hour,0,0)

k=find(mdnvect==mdn);

ts(k)
