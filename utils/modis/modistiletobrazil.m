function [values,indices,LonVect,LatVect,map,Rstructure]=modistiletobrazil(tilefile,Nskip);
% BrazilModisTile - get a consistent index from a Brazil Modis Tile
%
%
%  Example:
% 
% Nskip=4
% [values,indices,LonVect,LatVect,map,Rstructure]=modistiletobrazil('pa_br_evi_250_2014225_lapig',Nskip);
% mappingoff  % - to avoid bug in ionesurf disallow mapping tooldobx.
% ionesurf(LonVect,LatVect,map)
% addcoasts


%tilefile='pa_br_evi_250_2014353_lapig.tif';
%;

%% Preliminaries
% set up the matrix that embeds brazil
DeltaLat=0.00215682882230084;
LatLims=[-33.7534294901948 5.27223122051656] + DeltaLat*[-10 10];

DeltaLon= 0.00215682882230084;
LonLims=[-73.9932579615501 -34.7928941162324]+DeltaLon*[-20 20];

% note ... using Long as first dimension to be consistent with the GLI matlab
% convention.

LatVect=LatLims(1):DeltaLat:LatLims(end);
LonVect=LonLims(1):DeltaLon:LonLims(end);

BrazilEmbedMatrix=single(zeros(length(LonVect),length(LatVect)));

%%
[A,R] = geotiffread(tilefile);
A=A.';
A=A(:,end:-1:1);

LatStart=find(closeto(LatVect,R.Latlim(1),DeltaLat/1000));
LonStart=find(closeto(LonVect,R.Lonlim(1),DeltaLon/1000));

jj=LatStart:(LatStart+R.RasterSize(1)-1);
ii=LonStart:(LonStart+R.RasterSize(2)-1);
BrazilEmbedMatrix(ii,jj)=A(1:end,1:end);
clear A


% now downsample with Nskip
iiskip=ii(1:Nskip:end);
jjskip=jj(1:Nskip:end);


LatVect=LatVect(jjskip);
LonVect=LonVect(iiskip);
BrazilEmbedMatrix=BrazilEmbedMatrix(iiskip,jjskip);


values=BrazilEmbedMatrix(:);
map=BrazilEmbedMatrix;
Rstructure=R;
indices=[];

% 
% LatVect=linspace(R.Latlim(1),R.Latlim(2),R.RasterSize(1));
% LonVect=linspace(R.Lonlim(1),R.Lonlim(2),R.RasterSize(2));
% 
% latvds=LatVect(1:Nskip:end);
% lonvds=LonVect(1:Nskip:end);
% x=A(1:Nskip:end,1:Nskip:end).';
% Ads=x(:,end:-1:1);
% 
% 
% T1.latvds=latvds;
% T1.lonvds=lonvds;
% T1.Ads=Ads;
% T1.R=R;
