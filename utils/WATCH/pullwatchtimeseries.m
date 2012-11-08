function [mdnvect,ts]=pullwatchtimeseries(idx,basedir);
% pullwatchtimeseries


Ntimeseries=1:(365.25*100*8);

Nindices=length(find(idx));
ts=NaN(1:Nindices,1:Ntimeseries);

mdnvect=[];

%basedir=[iddstring '/Climate/reanalysis/WATCH/Tair_WFD/'];
basedir='./'

for yy=1902:1902;
            mdn0=datenum(yy,01,01,00,00,00);  % note this should be hardwired to Jan

    for mm=1:12
        FileName=[basedir 'Tair_WFD_' int2str(yy) sprintf('%02d',mm) '.nc']
        S=OpenGeneralNetCDF(FileName);
        
        % initial date string
          x=S(4).Attributes(4).attrvalue;
        
        
        mdn0=datenum(yy,01,01,00,00,00);  % note this should be hardwired to Jan
        mdn=mdn0+S(4).Data/(24*3600);  %mdn in units of days.  so go from seconds to days.
       % datestr(double(mdn(1)))
        tstmp=S(6).Data(idx,:);
        
        kk=(length(mdnvect)+1 ):length(mdnvect)+length(mdn);
        
        ts(1:Nindices,kk)=tstmp;
        
        mdnvect=[ mdnvect ; mdn];
        
    end
end

return

% code to get timeseries for north america
ii=ContinentOutline('Northern America');
ii5min=aggregate_rate(ii,6);
jj=ii5min>.5;

load WFDindices iivect

outblanklogical=datablank(0,'30min');
outblankindices=datablank(0,'30min');
outblanklogical(iivect)=1;
outblankindices(iivect)=iivect;

logicalkeep=(jj & outblanklogical);

indices=outblankindices(logicalkeep);

indices=indices(indices>0);



[mdnvect,ts]=pullwatchtimeseries(indices,basedir); 

