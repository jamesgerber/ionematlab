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



if nargin==1
    Nskip=1
end


disp([' opening tile ' tilefile ]);
tic
%tilefile='pa_br_evi_250_2014353_lapig.tif';
%;

%% Preliminaries
% set up the matrix that embeds brazil.  Call this matrix the Frame.
%DeltaLat=0.00215682882230084;
%LatLims=[-33.7534294901948 5.27223122051656] + DeltaLat*[-10 10];
%DeltaLon= 0.00215682882230084;
%LonLims=[-73.9932579615501 -34.7928941162324]+DeltaLon*[-20 20];

[DeltaLon,LonLims,LonVect,DeltaLat,LatLims,LatVect,FrameRasterSize]=modisrasterconstants(Nskip);



%FrameRasterSize=[18095 18176]+[5 5];

BrazilFrameMatrix=single(zeros(length(LonVect),length(LatVect)));
BrazilFrameMatrix=BrazilFrameMatrix-3000;
%%
[A,R] = geotiffread(tilefile);
A=A.';
A=A(:,end:-1:1);

LatStart=find(closeto(LatVect,R.Latlim(1),DeltaLat/1000));
LonStart=find(closeto(LonVect,R.Lonlim(1),DeltaLon/1000));

jj=LatStart:(LatStart+R.RasterSize(1)-1);
ii=LonStart:(LonStart+R.RasterSize(2)-1);



BrazilFrameMatrix(ii,jj)=A(1:end,1:end);
clear A



%%% these two lines baffle me.  not sure why I did that.
%jj=LatStart:(LatStart+FrameRasterSize(1)-1);
%ii=LonStart:(LonStart+FrameRasterSize(2)-1);


% now downsample with Nskip
ii=1:size(BrazilFrameMatrix,1);
jj=1:size(BrazilFrameMatrix,2);
iiskip=ii(1:Nskip:end);
jjskip=jj(1:Nskip:end);


LatVect=LatVect(jjskip);
LonVect=LonVect(iiskip);
BrazilFrameMatrix=BrazilFrameMatrix(iiskip,jjskip);


values=BrazilFrameMatrix(:);
map=BrazilFrameMatrix;
Rstructure=R;
indices=map;
indices(:)=1:numel(map);
toc
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
