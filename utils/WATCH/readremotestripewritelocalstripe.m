function [mdn,ts,stripeno]=ReadRemoteStripeWriteLocalStripe(idx,type,remotebasedir);
% ReadRemoteStripeWriteLocalStripe - getstripe across network
%
%  this is a version of getstripe.m which will look locally for a stripe,
%  if it doesn't find it, read it remotely, and then write it locally.
%  Useful for pulling over a minimum set of stripes to a working computer.


if nargin==0
    help(mfilename)
    return
end
if nargin==1
    type='precip';
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
    [md1,ts1]=getstripe(idx,'rain');
    [md2,ts2]=getstripe(idx,'snow');
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
end



%([iddstring 'Climate/reanalysis/WATCH/Rainf/stripes/'])

load([remotebasedir FileBase int2str(stripeno)]);
switch type
    case 'Tair'
        ts=Tair;
        save([basedir FileBase int2str(stripeno)],'mdnvect','Tair','notes');

    case 'rain'
        ts=rain;
        save([basedir FileBase int2str(stripeno)],'mdnvect','rain','notes');

    case 'snow'
        ts=snow;
        save([basedir FileBase int2str(stripeno)],'mdnvect','snow','notes');

end


mdn=mdnvect;
ts=ts(:);


