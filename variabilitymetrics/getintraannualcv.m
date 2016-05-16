function [M]=getinterannualcv(mdn,rain,snow,Tair,yr,varargin);
% Compute internnual cv of precipitation


if isnan(mdn)
   M.metricvalue=NaN;
   return
end
% assume mdn the same on every call

persistent monthvect yearvect

if isempty(monthvect)
    monthvect=str2num(datestr(mdn,5));
    yearvect=str2num(datestr(mdn,10));

end


%%
Nyears=length(unique(yearvect));
yearlist=unique(yearvect);

% 
% ii=find(yearvect==yr);
% % daily precipvect
% precipvect=(rain(ii))+snow(ii);
    

%% monthly precipvect
for m=1:12
jj=find(yearvect==yr & monthvect==m);
precipvect(m)=sum(rain(jj)+snow(jj));
end

%%

meanprecip=mean(precipvect);
stdprecip=std(precipvect);
CVprecip=stdprecip./meanprecip;


M.CV=CVprecip;
M.description='intraannual precip';
M.metricvalue=CVprecip;