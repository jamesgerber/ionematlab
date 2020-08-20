function [targetmatrix]=alignmatrixsubset(long,lat,matrix,targetlong,targetlat,tol,BoundaryValue);
% alignmatrixsubset - get an aligned a subset of a matrix 
%
%
%   [newmatrix]=alignmatrixsubset(long,lat,matrix,targetlong,targetlat,tol,BoundaryValue);
%
%
% see also startmatrixfromsouth startmatrixfromnorth
if nargin<6
    tol=1e-6;
end

if nargin<7
    BoundaryValue=0;
end


if abs(1-mean(diff(long))/mean(diff(targetlong)))>tol
    error([' delta long, delta targetlong out of tolerance (tol = ' num2str(tol) ')']);
end

if abs(1-mean(diff(lat))/mean(diff(targetlat)))>tol
    error([' delta lat, delta targetlat out of tolerance (tol = ' num2str(tol) ')  check north/south']);
end

% let's first embed long,lat,matrix into something a bit bigger

fatlongminApproximate=min(min(long),min(targetlong));
fatlongmaxApproximate=max(max(long),max(targetlong));

% now snap this to a grid based on deltalong
deltalong=mean(diff(long));
deltalat=mean(diff(lat));
% out of laziness, going to add 100 points in either direction.   Coudl
% figure out what is actually required but punting to future

fatlong  = (long(1)-100*deltalong):deltalong:long(end)+100*deltalong;
fatlat   =  (lat(1)-100*deltalat):deltalat:lat(end)+100*deltalat;

fatmat=ones(numel(fatlong),numel(fatlat))*BoundaryValue;

% now need to put matrix into fatmatrix
ii1=find(closeto(long(1),fatlong,deltalong/1000));
ii2=find(closeto(long(end),fatlong,deltalong/1000));
jj1=find(closeto(lat(1),fatlat,abs(deltalat)/1000));
jj2=find(closeto(lat(end),fatlat,abs(deltalat)/1000));

fatmat(ii1:ii2,jj1:jj2)=matrix;


% now can put fatmat onto targetmatrix
% now need to put matrix into fatmatrix
ii1=find(closeto(targetlong(1),fatlong,deltalong*tol));
ii2=find(closeto(targetlong(end),fatlong,deltalong*tol));
jj1=find(closeto(targetlat(1),fatlat,abs(deltalat)*tol));
jj2=find(closeto(targetlat(end),fatlat,abs(deltalat)*tol));

targetmatrix=fatmat(ii1:ii2,jj1:jj2);

