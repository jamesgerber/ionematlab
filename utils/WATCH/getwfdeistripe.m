function [mdn,ts,struct]=getWFDEIstripe(idx,type,basedatadir);
% getWFDEIstripe - get a stripe from the WFDEI dataset
%
%   getWFDEIstripe(stripenumber,type)  where type can be
%   'Rainf_WFDEI_CRU		Tair_WFDEI
%   Snowf_WFDEI_CRU		Tair_daily_WFDEI
%
%
%        stripenumber corresponds to an index into a 2160x1080 grid of the
%        world.  You can't just make up a stripenumber ... because they
%        only exist for points on a landmask.  That landmask is defined by
%        the WFDEI-elevation.nc dataset.   Don't overthink it - use the
%        example below.
%
%  This code only runs if you have the WFDEI stripes set up on your
%  computer.  Work on malthus, or see jamie for help.
%
%  Example
%
%    [mdnvect,tsvect,struct]=getWFDEIstripe(97729,'Rainf_WFDEI_CRU'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%    [mdnvect,tsvect,struct]=getWFDEIstripe(97729,'Tair_WFDEI'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%    [mdnvect,tsvect,struct]=getWFDEIstripe(97729,'Tair_daily_WFDEI'); 
%    figure
%    mdnplot(mdnvect,tsvect);
%    [mdnvect,tsvect,struct]=getWFDEIstripe(97729,'Snowf_WFDEI_CRU'); 
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
%
%
%  Here is how to make map of where the index points are
%ii=landmasklogical(zeros(2160,1080));
%newmap=ii*0;
%newmap(ii)=find(ii);
%nsg(newmap)

%% code to make stripes

%WFDEIVar='Tair_daily_WFDEI';
WFDEIVar=type;


if nargin<3  
    basedir=[iddstring '/Climate/reanalysis//WFDEI/stripes/'];
end
       
if nargin==3
    if isempty(basedatadir)
        basedir=[iddstring '/Climate/reanalysis//WFDEI/stripes/'];
    else
        basedir=basedatadir;
    end
end


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



