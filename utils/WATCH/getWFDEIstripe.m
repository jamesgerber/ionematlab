function [mdn,ts,struct]=getWFDEIstripe(idx,type);
% getWFDEIstripe
%
%   getWFDEIstripe(getWFDEIstripe,type)  where type can be
%   'Rainf_WFDEI_CRU		Tair_WFDEI
%   Snowf_WFDEI_CRU		Tair_daily_WFDEI
%
%
%  Example
%
%    [mdnvect,tsvect,struct]=getWFDEIstripe(237409,'Rainf_WFDEI_CRU'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%    [mdnvect,tsvect,struct]=getWFDEIstripe(237409,'Tair_WFDEI'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%    [mdnvect,tsvect,struct]=getWFDEIstripe(237409,'Tair_daily_WFDEI'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%    [mdnvect,tsvect,struct]=getWFDEIstripe(237409,'Snowf_WFDEI_CRU'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%
%
%
%  S=OpenGeneralNetCDF([iddstring 'Climate/reanalysis/WFDEI/WFDEI-elevation.nc']);
%x=S(end).Data(:,end:-1:1);
%goodpoints=find(x < 1e10);
%
%ii=(x < 1e10);
%
%y=datablank(x);
%y(goodpoints)=goodpoints;
%
%  % now y is a matrix whose values correspond to the stripe number.
%
%    ii=landmasklogical(zeros(2160,1080));
%    [outline] = CountryCodetoOutline('IND24');
%    outline10min=aggregate_rate(outline,6);
%    outline10min=outline10min>0.5;
%
%    m=find(outline10min);
%
%    for j=1:length(m)
%    [mdn,ts1]=getWFDEIstripe(m(j),'Rainf_WFDEI_CRU');
%    [mdn,ts2]=getWFDEIstripe(m(j),'Snowf_WFDEI_CRU');
%    [mdn,ts3]=getWFDEIstripe(m(j),'Tair_WFDEI');
%    DS(j).mdn=mdn;
%    DS(j).rain=ts1;
%    DS(j).snow=ts2;
%    DS(j).Tair=ts3;
%    end


%% code to make stripes

%WFDEIVar='Tair_daily_WFDEI';
WFDEIVar=type;

basedir = [iddstring 'Climate/reanalysis/WFDEI/stripes'];

for j=1:length(idx);
        FileName=[basedir '/' WFDEIVar '/' WFDEIVar int2str(idx(j))];
        x=load(FileName);
     %   mdnvect=x;
     
     
     
     if j==1
         N=length(x.tsvect);       
         ts(1:N,1:length(idx))=single(-99999);
         mdn=x.mdnvect(:).';
     end
          
     % using 1:N on left, colon on right to catch the unexpected case where
     % the number of rows changes at different points. 
     ts(1:N,j)=x.tsvect(:).';  

end




struct.notes=x.notes;
struct.indices=idx;



