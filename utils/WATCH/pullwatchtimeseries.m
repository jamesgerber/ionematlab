function [mdnvect,ts]=pullwatchtimeseries(idx,basedir);
% pullwatchtimeseries


Ntimeseries=(365.25*100*8);

Nindices=length(find(idx));
ts=single(zeros(Nindices,Ntimeseries));

mdnvect=[];

if nargin==1
    basedir=[iddstring '/Climate/reanalysis/WATCH/Tair_WFD/'];
end
    %basedir='./'

for yy=1902:2001;
            mdn0=datenum(yy,01,01,00,00,00);  % note this should be hardwired to Jan

    for mm=1:12
        FileName=[basedir 'Tair_WFD_' int2str(yy) sprintf('%02d',mm) '.nc']
        S=OpenGeneralNetCDF(FileName);
        
        % initial date string
       %   x=S(4).Attributes(4).attrvalue
        
        
        mdn0=datenum(yy,01,01,00,00,00);  % note this should be hardwired to Jan
        mdn=mdn0+S(4).Data/(24*3600);  %mdn in units of days.  so go from seconds to days.
       % datestr(double(mdn(1)))
        tstmp=S(6).Data(idx,:);
        
        kk=(length(mdnvect)+1 ):length(mdnvect)+length(mdn);
        
        ts(1:Nindices,kk)=single(tstmp);
        
        mdnvect=[ mdnvect ; mdn];
        
    end
end

return

% code to get timeseries for north america
ii=ContinentOutline('Northern America');

ii=CountryCodetoOutline('USA');

ii5min=aggregate_rate(ii,6);
jj=ii5min>.5;

% us corn belt

D=OpenNetCDF('Belt_North_America_maize_75_30min_perc.nc');
jj=logical(D.Data);



load WFDindices iivect

outblanklogical=datablank(0,'30min');
outblankindices=datablank(0,'30min');
outblanklogical(iivect)=1;
outblankindices(iivect)=1:length(iivect);
%outblankindices(iivect)=iivect;

logicalkeep=(jj & outblanklogical);

indices=outblankindices(logicalkeep);

indices=indices(indices>0);

[mdnvect,ts]=pullwatchtimeseries(indices); 
save USAcornbelt mdnvect ts indices outblanklogical outblankindices logicalkeep


%% code to make timeseries stripes

mkdir stripes

jj=1:67240;
Nsteps=100;
endpoints=round(linspace(1,67240,Nsteps));

for j=1:(Nsteps-1);
j
    ii=endpoints(j):endpoints(j+1);
    [mdnvect,ts]=pullwatchtimeseries(ii); 

    
    
    for m=ii
        FileName=[basedir '/Tair_WFD_pt' int2str(m)];
        Tair=ts(:,m);
        notes.processdate=datestr(now);
        save(FileName,'Tair','mdnvect','notes')
    end
end

        

    
    