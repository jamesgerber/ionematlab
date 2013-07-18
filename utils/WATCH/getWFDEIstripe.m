function [mdnvect,ts,struct]=getWFDEIstripe(idx,type);
% getWFDEIstripe
%
%   getWFDEItimeseries(getWFDEIstripe,type)  where type can be
%   'Rainf_WFDEI_CRU		Tair_WFDEI
%   Snowf_WFDEI_CRU		Tair_daily_WFDEI
%

%% code to make stripes

%WFDEIVar='Tair_daily_WFDEI';
WFDEIVar=type;

basedir = [iddstring 'Climate/reanalysis/WFDEI/stripes'];

for j=1:length(idx);
        FileName=[basedir '/' WFDEIVar '/' WFDEIVar int2str(idx(j))];
        x=load(FileName);
     %   mdnvect=x;
end

mdnvect=x.mdnvect;
ts=x.tsvect;
struct=x;

