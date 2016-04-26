% Calculate climate indices over a region


% preliminaries

ver='O';   % set a version number

extraargs=[];


% pick a region   'agland','landmask','pasture','cropland','iowa'
mask='landmask';

% pick an index and associated variables.  This has to be a function which
% is on the matlab path, which returns a structure M which contains the
% field metricvalue first input to function must be
% mdn,Rainf,Snowf,Tair,year
%
%  associated variables include rst ( % rain, snow, temperature)
%  and yrvecct


%%%%%%%%%%%%%%%%%%%%%%%%%
%  getinterannualcv     %
%%%%%%%%%%%%%%%%%%%%%%%%%
% metricfunctionhandle=@getinterannualcv;
% %metricfunctionextraarguments={'maize'};  % just an example
% rst=[1 1 0 ];  % rain, snow, temperature.
% yrvect=1;

%%%%%%%%%%%%%%%%%%%%%%%%%
%  getintraannualcv     %
%%%%%%%%%%%%%%%%%%%%%%%%%
% metricfunctionhandle=@getintraannualcv;
% %metricfunctionextraarguments={'maize'};  % just an example
% rst=[1 1 0 ];  % rain, snow, temperature.
% yrvect=[1979:2012];

%%%%%%%%%%%%%%%%%%%%%%%%%
%  getKDD     %
%%%%%%%%%%%%%%%%%%%%%%%%%
metricfunctionhandle=@getKDD;
%metricfunctionextraarguments={'maize'};  % just an example
rst=[0 0 1];  % rain, snow, temperature.
yrvect=[1979:2012];
Tcrit=32;
extraargs{1}=Tcrit;



%% extra things
croplist={'maize'} ; % (in case an index requires a crop)

% this has to be defined.  if you leave it empty, look in default location.
% You might want it to point to an external drive or something.
basedatadir='';

% 0,1,2 are values.  0 don't undersample, 2 most undersampling
undersampleforspeed=0;





%% pick a mask
switch mask
    
    case 'cropland'
        jj=cropmasklogical;
        ii=aggregate_rate(jj,6);
        iikeep=ii>.8;
    case 'pasture'
        jj=pasturemasklogical;
        ii=aggregate_rate(jj,6);
        iikeep=ii>.8;
    case 'agland'
        jj=agrimasklogical;
        ii=aggregate_rate(jj,6);
        iikeep=ii>.8;
    case 'landmask';
        jj=landmasklogical;
        [~,~,long2,lat2]=inferlonglat(jj);
        jj=jj & lat2>-60;
        ii=aggregate_rate(jj,6);
        iikeep=ii>.8;
    case 'iowa'
        [ii] = CountryCodetoOutline('USA19');
        outline10min=aggregate_rate(ii,6);
        iikeep=outline10min>0.8;
end


%%
switch undersampleforspeed
    case 0
        % do nothing
    case 1
        ii=repmat([1 0; 0 0],360,180);   % thin down to every 1 degree
        iikeep=iikeep>0 & ii;
        
    case 2
        ii=repmat([1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0],180,90);   % thin down to every 2 degrees
        iikeep=iikeep>0 & ii;
end


clear Mcount
initialfail=[];

pointslist=find(iikeep);   % these are the indices of the points we will actually analyze.
disp(['  About to analyze ' num2str(length(pointslist)) ' points ']);


%    yrvectMcount=yrvect;
for j=1:length(pointslist)
    j
    thisindex=pointslist(j);
    
    counter=1;
    
    
    
    
    try
        mdn=NaN;  % give some values
        Tair=NaN;
        Rainf=NaN;
        Snowf=NaN;
        
        %                [mdn,Tair]=getWFDEIstripe(thisindex,'Tair_WFDEI',basedatadir);
        if rst(1)==1
            [mdn,Rainf]=getWFDEIstripe(thisindex,'Rainf_daily_WFDEI_CRU',basedatadir);
        end
        if rst(2)==1
            [mdn,Snowf]=getWFDEIstripe(thisindex,'Snowf_daily_WFDEI_CRU',basedatadir);
        end
        if rst(3)==1
            [mdn,Tair]=getWFDEIstripe(thisindex,'Tair_WFDEI',basedatadir);
        end
        
    catch
        
        Mcount(counter,j)=NaN;
        disp([' WFDEI problem for point ' int2str(thisindex)]);
        initialfail(end+1)=thisindex;
    end
    
    
    for jyr=1:length(yrvect);
        if isempty(extraargs)
            M=feval(metricfunctionhandle,mdn, Rainf, Snowf, Tair, yrvect(jyr));
        else
            M=feval(metricfunctionhandle,mdn, Rainf, Snowf, Tair, yrvect(jyr),extraargs);
        end
        Mcount(jyr,j)=M.metricvalue;
    end
end
%
%mean value of the metric
map=datablank(NaN,'30min');
map(pointslist)=mean(Mcount,1);
nsg(map)


% now make a map of metric in the first year

map=datablank(NaN,'30min');
map(pointslist)=Mcount(1,:);
nsg(map)

%%
% if length(yrvect) greater than 1 map the differences of the average
% metrics
if length(yrvect)>1
    iiperiod1=1:floor(length(yrvect)/2);
    iiperiod2=(iiperiod1(end)+1):length(yrvect);
    
    MC1=mean(Mcount(iiperiod1,:),1);
    MC2=mean(Mcount(iiperiod2,:),1);
    
    
    trendmap=datablank(NaN,'30min');
    
    trendmap(pointslist)=(MC2-MC1);
    clear NSS
    NSS.title=[' Change in ' M.description ];
      NSS.filename='figures/';
    NSS.resolution='-r450';
    NSS.modifycolormap='stretch';
    NSS.stretchcolormapcentervalue=0;
    nsg(trendmap,NSS)
    
    %%
    trendmap(pointslist)=MC2./MC1;
    MC1map=datablank(NaN,'30min');
    MC1map(pointslist)=MC1;
     clear NSS
    NSS.title=[' Percent change in ' M.description ];
      NSS.filename='figures/';
    NSS.resolution='-r450';
    NSS.modifycolormap='stretch';
    NSS.stretchcolormapcentervalue=0;
    NSS.units='%';
    NSS.caxis=[-10 10];
    NSS.logicalinclude=logical(aggregate_rate(cropmasklogical,6));
    
    nsg(trendmap,NSS)
    
    
    
    
end