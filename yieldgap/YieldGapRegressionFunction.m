function OutputStructure=YieldGapFunction(FlagStructure)
%% YieldGapFunction   New Yield Gap Work - J. Gerber, N. Mueller
%
%  SYNTAX
%      YieldGapFunction  Will compute yield gaps according to
%      default settings.
%
%
%  Example
%
%  FS.PercentileForMaxYield=95;
%  FS.MinNumberHectares=10;
%  FS.CropNo=5;
%  FS.WetFlag='TMI';
%  FS.ClimateSpaceRev='F';
%  FS.ClimateSpaceN=10;
%  FS.ibinlist=0;
%  FS.QuietFlag=0;
%  FS.MakeGlobalMaps=1;
%  FS.MakeBinWeightedYieldGapPlotFlag=1;
%  FS.ClimateLibraryDir='../ClimateSpaces';
%  OutputStructure=YieldGapRegressionFunction(FS);
%
%
%


%% Set Default Flags
ApplyAreaFilterFlag=1;

IndividualAreaMethod='AllBinFifthPercentile';
%CropNo=5;
%IndividualAreaMethod='fixed';
%WetFlag='prec';
%HeatFlag='GDD';

MinNumberPointsPerBin=1;
MinNumberHectares=1;
MinNumberCountries=0;  % this doesn't do anything
MinNumberYieldValues=1;

HeatFlag='GDD';
%WetFlag='TMI';

QuietFlag=0;  %if 1, be quiet.

OutputBinDQ=0;
BinDQFileName='BinDataQuality';

MakeBoxPlot=0;
MakeBinPlots=0;
MakeAllBinsBoxPlot=0;
MinNumPointsAllBinsBoxPlot=200;
ibinlist=0;   %if 0, do all bins.
MakeGlobalMaps=0;  % These are yield maps
SurfacePlotOfAreaInClimateSpaceFlag=0;
DistributionOfAreaPlotFlag=0;
MakePotentialYieldMapFlag=0;  %if "2" then only do calculation
PredictYieldPlots=0; %regressiony things
PointsPerBinPlotsFlag=0;
PercentileForMaxYield=95;
MakeBinWeightedYieldGapPlotFlag=0;

% Now override defaults with FlagStructure

clear j


if nargin==1
    expandstructure(FlagStructure)  %Cheating with matlab.  step through with
                                    %debugger to understand.
end

N  =ClimateSpaceN;

%%% Preliminaries

% Get Area per grid cell 
[Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;
[Lat2d,Long2d]=meshgrid(Lat,Long);


potentialyield=NaN*ones(size(FiveMinGridCellAreas));

AllIndices=1:9331200;

%%% Read from crops.csv
[DS,NS]=CSV_to_structure('crops.csv');

%for j=1:length(NS.col1);

j=CropNo
%%%%%%%% Crop specific
cropname=NS.col1{j};
cropfilename=NS.col2{j};
croppath=NS.col3{j};
suitpath=NS.col4{j};
suitbins=NS.col5(j);
cropconv=NS.col6(j);
areafilter=NS.col7(j);

if QuietFlag==0
    disp(['Working on ' cropname]);
end

%% read in crop netCDF file, extract area fraction.
CropData=OpenNetCDF(croppath);
AreaFraction=CropData.Data(:,:,1);
AreaFraction(find(AreaFraction>1e10))=NaN;

Yield=CropData.Data(:,:,2);
clear CropData
cropname=strrep(cropname,' ','_');
CultivatedArea=AreaFraction.*FiveMinGridCellAreas;
Production=CultivatedArea.*Yield;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get GDD and TMI
SystemGlobals
[Long,Lat,TMI]=OpenNetCDF([DERIVEDCLIMATEDATAPATH '/TMI.nc']);


%% find GDD Temp
a=DS.Suitability{j};
GDDTempstr=a(end-6);
Nstr=int2str(N);
GDDFile=[];

[Long,Lat,GDD]=OpenNetCDF([DERIVEDCLIMATEDATAPATH 'GDD' GDDTempstr '.nc']);



%%% Calculate 5% of bin areas.  only care about areas with Yield Data.

ii=find(isfinite(Production) & Yield < 1e10 & Yield>0);

AreaValues=CultivatedArea(ii);
AVsort=sort(AreaValues);
cumulativeAV=cumsum(AVsort);
cAVnorm=cumulativeAV/max(cumulativeAV);
[iiAV]=min(find(cAVnorm>=.05));
FifthPercentileArea=AVsort( iiAV);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Have now set up
%matrices, can loop over bins and look at each bin individually and
%get yield gaps.

% limit individual bins based on area.

switch IndividualAreaMethod
    case 'fixed'
        IndicesToKeep=find(  CultivatedArea >= areafilter);
    case 'AllBinFifthPercentile'
        IndicesToKeep=find(  CultivatedArea >= FifthPercentileArea);
        LogicalToKeep=(  CultivatedArea >= FifthPercentileArea);
    otherwise
        error('don''t know how to filter area this way')
        
end


% Now we have our binfilter (i.e. those points which are in the bin
% and have appropriate area characteristics)

MaxWJP=0;
figure('position',[30 30 1000 1500]);
TMIvals=[0:.2:2];
TMIvals(end+1)=10;
for j=1:length(TMIvals)-1;
    
    ii=find( TMI >= TMIvals(j) & TMI < TMIvals(j+1) & Yield<1e10 & isfinite(CultivatedArea) ...
        & LogicalToKeep);
    
    TMIvals(j)
    TMIvals(j+1)
    
    % joint probability distribution
    
    g=GDD(ii);
    y=Yield(ii);
    area=CultivatedArea(ii);
    TotalAreaThisSlice(j)=sum(CultivatedArea(ii));
    [jp,GDDbins,TMIbins]=GenerateJointDist(g,y,30,30,area);
    set(gcf,'renderer','zbuffer')
    subplot(4,3,j)
    cs=surface(double(GDDbins),double(TMIbins),double(jp).');
    %colorbar
    title('Joint distribution')
    shading flat
    title(['TMI >= ' num2str(TMIvals(j)) '.  TMI < ' num2str(TMIvals(j+1)) ])
    %  plot(GDD(ii),Yield(ii),'.')
    %xlabel('GDD')
    ylabel('Yield')
    MaxWJP=max(MaxWJP,double(max(max(jp))));
end

for m=1:j %since j is number of subplots
    subplot(4,3,m);
    caxis([0 MaxWJP]);
end
h12=subplot(4,3,12)
set(h12,'visible','off')
colorbar
caxis([0 max(TotalAreaThisSlice)]);

    
ubertitle(['Yield vs GDD.  TMI bins.  Crop = ' cropname]);


OutputStructure=[];



    
