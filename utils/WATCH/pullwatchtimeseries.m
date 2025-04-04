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

for yy=1902:2002;
    %for yy=1957:1960;
    %       mdn0=datenum(yy,01,01,00,00,00);  % note this should be hardwired to Jan
    
    % note that 1901_09 is missing
    
    for mm=1:12
        if ((yy==1901) & (mm~=12) ) |((yy==2002) & (mm~=1) )
            
            disp(['skipping ' datestr(double(datenum(yy,mm,01,00,00,00)))]);
        else
            FileNameBase=['Tair_WFD_' int2str(yy) sprintf('%02d',mm) ];
            FileName=[basedir FileNameBase '.nc'];
           disp(['hard wired to read the ncmat on Disk1'])
       %     S=OpenGeneralNetCDF(FileName);
           
           x=load(['/Volumes/Disk1/Climate/ncmat/' FileNameBase '.mat']);
           S=x.Svector;
           
           disp(FileName)
            % initial date string
            %   x=S(4).Attributes(4).attrvalue
            
            
            mdn0=datenum(yy,mm,01,00,00,00);  % note this should be hardwired to Jan
            ttemp=S(4).Data-S(4).Data(1);
            mdn=mdn0+ttemp/(24*3600);  %mdn in units of days.  so go from seconds to days.
            % datestr(double(mdn(1)))
            tstmp=S(6).Data(idx,:);
            datestr(double(mdn(1)));
            
            kk=(length(mdnvect)+1 ):length(mdnvect)+length(mdn);
            
            ts(1:Nindices,kk)=single(tstmp);
            
            mdnvect=[ mdnvect ; mdn];
        end
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

%pause(1800)

basedir = 'stripes';
jj=1:67240;
Nsteps=100;
endpoints=round(linspace(1,67240,Nsteps));

for j=62:(Nsteps-1);
    j
    ii=endpoints(j):endpoints(j+1);
    [mdnvect,ts]=pullwatchtimeseries(ii);
    
    
    
    for m=1:length(ii)
        
        FileName=[basedir '/Tair_WFD_pt' int2str(ii(m))];
        Tair=ts(m,:);
        notes.processdate=datestr(now);
        save(FileName,'Tair','mdnvect','notes')
    end
end




