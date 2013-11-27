function [mdn,ts,stripeno]=getstripe(idx,type);
% getstripe
%
%   getstripe(index,type)  where
%    index is location on a 30min x 30min grid
%    type is 'Tair','rain','snow','precip'
%
%
%    % Example
%    ii=landmasklogical(zeros(720,360));
%    [outline] = CountryCodetoOutline('USA01');
%    outline30min=aggregate_rate(outline,6);
%    outline30min=outline30min>0.5;
%
%    m=find(outline30min);
%
%    [mdn,ts1]=getstripe(m(1),'rain');
%    [mdn,ts2]=getstripe(m(1),'snow');
%
%
%    % Example 2 : save a bunch of data
%    useful to run this on malthus
%
%    ii=landmasklogical(zeros(720,360));
%    [outline] = CountryCodetoOutline('IND24');
%    outline30min=aggregate_rate(outline,6);
%    outline30min=outline30min>0.5;
%
%    m=find(outline30min);
%
%    for j=1:length(m)
%    [mdn,ts1]=getstripe(m(j),'rain');
%    [mdn,ts2]=getstripe(m(j),'snow');
%    [mdn,ts3]=getstripe(m(j),'Tair');
%    DS(j).rain=ts1;
%    DS(j).snow=ts2;
%    DS(j).Tair=ts3;
%    end
%    save IND24 DS mdn
if nargin==0
    help(mfilename)
    return
end
if nargin==1
    type='precip';
end


if length(idx)>1
    for j=1:length(idx);
        [mdn,tsvect(:,j),stripeno(j)]=getstripe(idx(j),type);
    end
    ts=tsvect;
    return
end

        
        





persistent iivect ii

if isempty(iivect)
    load('WFDindices','iivect')   % should be in source folder
    ii=datablank(0,'30min');
    ii(iivect)=iivect;
end

if isempty( intersect(idx,iivect)  )
    warning([' this index does not correspond to a point on the landmask ']);
    mdn=[];
    ts=[];
    return
end




if isequal(type,'precip')
    [md1,ts1,stripeno]=getstripe(idx,'rain');
    [md2,ts2,stripeno]=getstripe(idx,'snow');
    mdn=md1;
    ts=ts1+ts2;
    return
end







stripeno=find(iivect==idx);





switch type
    case 'Tair'
        basedir=[iddstring '/Climate/reanalysis/WATCH/Tair/stripes/'];
        FileBase='Tair_WFD_pt';
    case 'rain'
        basedir=[iddstring '/Climate/reanalysis/WATCH/Rainf/stripes/'];
        FileBase='rain_pt';
    case 'snow'
        basedir=[iddstring '/Climate/reanalysis/WATCH/Snowf/stripes/'];
        FileBase='snow_pt';
    otherwise 
        error([' need to ask for Tair rain or snow, not ' type ]);
end



%([iddstring 'Climate/reanalysis/WATCH/Rainf/stripes/'])

load([basedir FileBase int2str(stripeno)]);

switch type
    case 'Tair'
        ts=Tair;
    case 'rain'
        ts=rain;
    case 'snow'
        ts=snow;
end


mdn=mdnvect;
ts=ts(:);


