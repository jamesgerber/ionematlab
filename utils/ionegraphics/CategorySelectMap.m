function CategorySelectMap(Data,cmap,backdata,bmap);
% CATEGORYSELECTMAP - interactive category selection tool
%
%   Syntax:
%  CategorySelectMap(Data,cmap,backdata,bmap);
%
% Creates an interactive figure which lets the user click on a spot on the
% map to highlight it and all other areas with the same value. If provided,
% it will display another data set behind the primary one. (By default, a
% medium-quality composite satellite image of earth is used.) This data set
% can be an indexed image at 2160x4320 pix. To make an image display
% properly on a map projection, use the following:
% CategorySelectMap(Data,cmap,flipud(rot90(backdata)),bmap)
% Higher-resolution colormaps will look much nicer but may also seriously
% impact runtime and space-efficiency.
%
%
% Example
%
%  load([iddstring 'YieldGap/AreaFiltered_Soil/' ...
%     'YieldGap_Maize_MaxYieldPct_95_AreaFilteredClimateSpaceWithSoil_10x10_prec.mat'])
%  CategorySelectMap(OS.ClimateMask)
%
%
%  AMT
%  July 2010

if nargin==0
    help(mfilename)
    return
end

if (nargin==1)
    cmap=jet(500);
end

if (nargin<4)
    bmap=jet(500);
end

if (nargin<3)
    load worldindexed
    bmap=immap;
    backdata=flipud(rot90(im));
end


Data=double(Data);

cmap(1,1)=.7;
cmap(1,2)=.7;
cmap(1,3)=.7;
tmp=size(cmap,1)*2
cmap(size(cmap,1)+1:tmp,:)=.7;
size(cmap)

tmp=size(bmap,1)*2
bmap(size(bmap,1)+1:tmp,:)=.7;
size(bmap)

[Long,Lat]=InferLongLat(Data);
Units='';

RedLong=Long;
RedLat=Lat;
RedData=Data;


%% invert data to conform with matlab standard

RedLat=RedLat(end:-1:1);
RedData=RedData(:,end:-1:1);
backdata=backdata(:,end:-1:1);

RedData=RedData/2;
backdata=backdata/2;

hfig=figure;

% calculate place to put figure
if hfig<30
    XStart=100+30*hfig;
    YStart=800-20*hfig;
else
    XStart=100;
    YStart=800;
end


set(gcf,'renderer','zbuffer');

pos=get(hfig,'position');
newpos=[XStart YStart pos(3)*1.5 pos(4)*(0.9)];
%set(hfig,'position',[XStart YStart 842  440]);
set(hfig,'position',newpos);
%mps=get(0,'MonitorPositions');

%pos=pos.*[1 1 1.5 .9];
%set(hfig,'Position',pos);
set(hfig,'Tag','IonEFigure');

% Establish a UserDataStructure

  hm=axesm('robinson')
  NumPointsPerDegree=12*numel(RedLat)/2160;
  R=[NumPointsPerDegree,90,-180]
  h=meshm(double(RedData.'),R);
  shading flat;
colormap(gca,cmap);
caxis([0 max2d(RedData)*2+1]);
UserDataStructure.Fig=hfig;
UserDataStructure.CMap=cmap;
UserDataStructure.DataAxisHandle=gca;
UserDataStructure.Lat=RedLat;
UserDataStructure.Long=RedLong;
UserDataStructure.Data=RedData;

colorbar('hide');
shading flat

UserDataStructure.Back=backdata;
UserDataStructure.BMap=bmap;
set(hfig,'UserData',UserDataStructure);

selectCategory('Initialize');
AddCoastCallback('Initialize');
zoomButtons('Initialize');

clear NextButtonCoords
position=NextButtonCoords;
position(4)=100;
ConsoleAxisHandle=axes('units','pixels','Position',position);
set(ConsoleAxisHandle,'units','normalized');
set(ConsoleAxisHandle,'visible','off');

vis=get(UserDataStructure.DataAxisHandle,'visible');
set(UserDataStructure.DataAxisHandle,'visible',vis);
axes(UserDataStructure.DataAxisHandle);


end

function [Long,Lat]=InferLongLat(Data)

if nargin==0
    help(mfilename);
    return
end

  [Nrow,Ncol,Level]=size(Data);

  tmp=linspace(-1,1,2*Nrow+1);
  Long=180*tmp(2:2:end).';
  
  tmp=linspace(-1,1,2*Ncol+1);
  Lat=-90*tmp(2:2:end).';
end