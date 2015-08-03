function YieldAreaPlots(crop,PFS,NSSBase,ExternalMask)
%   YieldAreaPlots
%
%   Syntax
%      YieldAreaPlots(crop,PFS,NSSBase,ExternalMask)
%  example
%
%  clear NSSBase
%  NSSBase.fastplot='on';
%
%  PFS.AreaFilter=1;
%  PFS.YieldPlotFlag=1;
%  PFS.AreaPlotFlag=0;
%  PFS.TitleSuffix='';
%  PFS.FileNameBase='';
%  crop='wheat'
%  YieldAreaPlots(crop,PFS,NSSBase,DataBlank(1));


%
S=OpenNetCDF([iddstring '/Crops2000/crops/' crop '_5min.nc'])
Area=S.Data(:,:,1);
Yield=S.Data(:,:,2);

cropdisplayname=cropnametodisplayname(crop);

%% Yield
NSS=NSSBase;
NSS.Units='tons/ha';
NSS.TitleString=lower([cropdisplayname ' yield ' PFS.TitleSuffix ' ']);
NSS.cmap='revsummer';
NSS.FileName=[PFS.FileNameBase NSS.TitleString];


if PFS.AreaFilter==1
    LogicalIncludeArea=AreaFilter(Area,Area,0.95);
    NSS.LogicalInclude=(LogicalIncludeArea & ExternalMask);
else
    NSS.LogicalInclude=(ExternalMask);
end

if PFS.YieldPlotFlag==1
    NSO=NiceSurfGeneral(Yield,NSS);
    %      MakeGlobalOverlay(NSO.Data,NSS.cmap,NSO.coloraxis,...
    %          ['./Overlay_' crop '_yield.png'],0.5);
end

%% Area

NSS=NSSBase;
NSS.Units='tons/ha';
NSS.TitleString=lower([cropdisplayname ' area ' PFS.TitleSuffix ' ']);
NSS.cmap='area2';
NSS.Units='% of total land area';
NSS.colorbarpercent='on';
NSS.FileName=[PFS.FileNameBase NSS.TitleString];

if PFS.AreaFilter==1
    LogicalIncludeArea=AreaFilter(Area,Area,0.95);
    NSS.LogicalInclude=(LogicalIncludeArea & ExternalMask);
else
    NSS.LogicalInclude=(ExternalMask);
end

if PFS.AreaPlotFlag
    NSO=NiceSurfGeneral(Area*100,NSS);
    %      MakeGlobalOverlay(NSO.Data,NSS.cmap,NSO.coloraxis,...
    %          ['./Overlay_' crop '_yield.png'],0.5);
end




return

%%
personalpreferences('maxnumfigsNSG' ,      [4])

crop='cassava';

PFS.YieldPlotFlag=1;
PFS.AreaPlotFlag=1;
PFS.TitleSuffix='';
PFS.KMZFlag=0;
PFS.FileNameBase='';
PFS.AreaFilter=1;

NSSBase.PlotArea='africa';'southeastasia';'brazil';'southeastasia'; 'china';
NSSBase.FastPlot='off';
NSSBase.coloraxis=[.98];

ExternalMask=ones(size(DataMaskLogical));
YieldAreaPlots(crop,PFS,NSSBase,ExternalMask)
%%
YieldAreaPlots('soybean',PFS,NSSBase,ExternalMask)
close all

YieldAreaPlots('sugarcane',PFS,NSSBase,ExternalMask)
YieldAreaPlots('maize',PFS,NSSBase,ExternalMask)
YieldAreaPlots('yams',PFS,NSSBase,ExternalMask)
YieldAreaPlots('sorghum',PFS,NSSBase,ExternalMask)

%% plot them all
cl=CropList;
PFS.YieldPlotFlag=1;
PFS.AreaPlotFlag=1;
PFS.TitleSuffix='';
PFS.KMZFlag=0;
PFS.FileNameBase='';
PFS.AreaFilter=1;

NSSBase.FastPlot='off';
NSSBase.coloraxis=[.98];

ExternalMask=ones(size(DataMaskLogical));
for j=1:length(cl)
YieldAreaPlots(cl{j},PFS,NSSBase,ExternalMask);
end

