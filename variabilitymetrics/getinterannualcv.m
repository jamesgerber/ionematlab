function [M]=getinterannualcv(mdn,rain,snow,yrvect,varargin);
% Compute internnual cv of precipitation

if length(yrvect)>1
    error('this function only returns a scalar metricvalue')
end

% assume mdn the same on every call

persistent monthvect yearvect

if isempty(monthvect)
    monthvect=str2num(datestr(mdn,5));
    yearvect=str2num(datestr(mdn,10));

end
%%
%Nyears=length(find(monthvect==1))/31;
Nyears=length(unique(yearvect));
yearlist=unique(yearvect);
for j=1:Nyears
    thisyear=   yearlist(j);
    ii=yearvect==yearlist(j);

    sumprecip(j)=sum(rain(ii))+sum(snow(ii));
    
end

meanprecip=mean(sumprecip);
stdprecip=std(sumprecip);
CVprecip=stdprecip./meanprecip;


M.CV=CVprecip;
M.description='interannual precip';
M.metricvalue=CVprecip;