function [M]=getinterannualcv(mdn,rain,snow,Tair,yr,varargin);
% Compute internnual cv of precipitation


% assume mdn the same on every call

persistent monthvect yearvect

if isempty(monthvect)
    monthvect=str2num(datestr(mdn,5));
    yearvect=str2num(datestr(mdn,10));

end
%%
Nyears=length(unique(yearvect));
yearlist=unique(yearvect);


ii=find(yearvect==yr);

precipvect=(rain(ii))+sum(snow(ii));
    
% this probably doesn't make much sense ... better perhaps to do monthly or
% weekely

meanprecip=mean(precipvect);
stdprecip=std(precipvect);
CVprecip=stdprecip./meanprecip;


M.CV=CVprecip;
M.description='intraannual precip';
M.metricvalue=CVprecip;