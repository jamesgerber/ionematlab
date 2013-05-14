function [mdnvect,ts]=getWFDEItimeseries(idx,type);
% getWFDEItimeseries
%
%   getWFDEItimeseries(indices,type)  where type can be
%   'Tair','rain','snow'

Ntimeseries=(365.25*30*8); % 30 years * days/year * 8 samples/day

Nindices=length(find(idx));
ts=single(zeros(Nindices,Ntimeseries));

mdnvect=[];
switch type
    case 'Tair_WFDEI'        
        basedir=[iddstring '/Climate/reanalysis/WFDEI/Tair_WFDEI/'];
        FileBase='Tair_WFDEI_';
    case 'Tair_daily_WFDEI'
        basedir=[iddstring '/Climate/reanalysis/WFDEI/Tair_daily_WFDEI/'];
        FileBase='Tair_daily_WFD_';
    case 'Rainf_WFDEI_GPCC'
        basedir=[iddstring '/Climate/reanalysis/WFDEI/Rainf/'];
        FileBase='Rainf_WFD_GPCC_';
    case 'snow'
        basedir=[iddstring '/Climate/reanalysis/WFDEI/Snowf/'];
        FileBase='Snowf_WFD_GPCC_';
end
%basedir='./'

for yy=1979:2009;
    %for yy=1957:1960;
    %       mdn0=datenum(yy,01,01,00,00,00);  % note this should be hardwired to Jan
    
    % note that 1901_09 is missing
    
    for mm=1:12
        if ((yy==1901) & (mm~=12) ) |((yy==2002) & (mm~=1) )
            
            disp(['skipping ' datestr(double(datenum(yy,mm,01,00,00,00)))]);
        else
            FileNameBase=[FileBase int2str(yy) sprintf('%02d',mm) ];
            FileName=[basedir FileNameBase '.nc'];
       %    disp(['hard wired to read the ncmat on Disk1'])
            S=OpenGeneralNetCDF(FileName);
           
        %   x=load(['/Volumes/Disk1/Climate/ncmat/' FileNameBase '.mat']);
        %   S=x.Svector;
           
           disp(FileName)
            % initial date string
            %   x=S(4).Attributes(4).attrvalue
            
            
            mdn0=datenum(yy,mm,01,00,00,00);  % note this should be hardwired to Jan
            ttemp=S(4).Data-S(4).Data(1);
            mdn=mdn0+ttemp/(24*3600);  %mdn in units of days.  so go from seconds to days.
            % datestr(double(mdn(1)))
            
            %% old code . doesn't work with WFDEI bec S(5).Data is 3D
          %  tstmp=S(5).Data(idx,:);
            
            %% new code / ugly version
            D=S(5).Data;
            for m=1:size(D,3);
              x=D(:,:,m);
              sz=size(x);

              
              tstmp(1:Nindices,m)=x(idx);

            end
            %% new code / non-ugly version
%            IND=subs2ref(720,360,size(D,3))
%
 %           
            
            %%
            datestr(double(mdn(1)));
            
            kk=(length(mdnvect)+1 ):length(mdnvect)+length(mdn);
            
            ts(1:Nindices,kk)=single(tstmp);
            
            mdnvect=[ mdnvect ; mdn];
            clear tstmp
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
jj=1:67420;
Nsteps=375;
endpoints=round(linspace(1,67420,Nsteps));

for j=(Nsteps-2):(Nsteps-1);
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


%% code to make rainf stripes

%pause(1800)

basedir = 'stripes';
mkdir(basedir)
jj=1:67420;
Nsteps=375;
endpoints=round(linspace(1,67420,Nsteps));

for j=(Nsteps-1);
    j
    ii=endpoints(j):endpoints(j+1);
    [mdnvect,ts]=getwatchtimeseries(ii,'rain');
    
    
    
    for m=1:length(ii)
        
        FileName=[basedir '/rain_pt' int2str(ii(m))];
        rain=ts(m,:);
        notes.processdate=datestr(now);
        save(FileName,'rain','mdnvect','notes')
    end
end


%% code to make snow stripes

%pause(1800)

basedir = 'stripes';
mkdir(basedir)
jj=1:67420;
Nsteps=375;
endpoints=round(linspace(1,67420,Nsteps));

for j=(Nsteps-1);
    j
    ii=endpoints(j):endpoints(j+1);
    [mdnvect,ts]=getwatchtimeseries(ii,'snow');
    
    
    
    for m=1:length(ii)
        
        FileName=[basedir '/snow_pt' int2str(ii(m))];
        snow=ts(m,:);
        notes.processdate=datestr(now);
        save(FileName,'snow','mdnvect','notes')
    end
end



