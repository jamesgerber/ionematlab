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
%  FS.CropNo=5;   % this can be a vector
%  FS.WetFlag='TMI';
%  FS.ClimateSpaceRev='F';
%  FS.ClimateSpaceN=5;  % this can be a vector
%  FS.ibinlist=0;
%  FS.QuietFlag=0;
%  FS.MakeGlobalMaps=1;
%  FS.MakeBinWeightedYieldGapPlotFlag=0;
%  FS.ClimateLibraryDir='../ClimateSpaces';
%  FS.OutputDirBase=[IoneDataDir 'YieldGap'];
%  FS.ExternalMask=[];
%  OutputStructure=YieldGapFunction(FS);
%
%  FS.csqirev='Ar1';
%

%%% first look to see if we can automatically load in file.  If not, create
%%% and save
FS=FlagStructure;
try
    OutputDirBase=FS.OutputDirBase;
catch
    systemglobals
    % For backwards compatibility
    OutputDirBase=[IoneDataDir 'YieldGap'];
end

if numel(FS.CropNo)>1 | numel(FS.ClimateSpaceN)>1
    c=0;
    Ncrop=numel(FS.CropNo);
    Nclim=numel(FS.ClimateSpaceN);
    for j=1:Ncrop
        for m=1:Nclim;           
            FS=FlagStructure;
            FS.CropNo=FlagStructure.CropNo(j);
            FS.ClimateSpaceN=FlagStructure.ClimateSpaceN(m);
            OutputStructure=YieldGapFunction(FS);
        end
    end
    return
end



try
    SystemGlobals
    switch FS.ClimateSpaceRev
        case {'F','H'}
            FileName=[OutputDirBase '/YieldGap_CropNo' int2str(FS.CropNo) ...
                'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_ClimateSpaceRev'  FS.ClimateSpaceRev ...
                '_' num2str(FS.ClimateSpaceN) '.mat'];
  
        case 'G'
               FileName=[OutputDirBase '/YieldGap_CropNo' int2str(FS.CropNo) ...
                   'MaxYieldPct_' num2str(FS.PercentileForMaxYield) ...
                '_ClimateSpaceRev'  FS.ClimateSpaceRev ...
                '_soilrev' FS.csqirev ...
                '_' num2str(FS.ClimateSpaceN) '.mat'];
    end
    
catch
    error(['Prob. defining filename.  need CropNo, ClimateSpaceRev, ClimateSpaceN']);
end

ForceRedo=0;

if FS.ibinlist~=0
    ForceRedo=1;
end
if exist(FileName)==2 & ForceRedo==0;
    load(FileName,'FS','OS');
    [RevNo]=GetSVNInfo;
    if ~isequal(RevNo,OS.RevData.CodeRevisionNo);
        warning([ mfilename ' revision no = ' num2str(RevNo) ' Stored file made with ' ...
            num2str(OS.RevData.CodeRevisionNo)]);
    end
    OutputStructure=OS;
    return
end

% Set Default Flags
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
MakeGlobalMapsSoil=0;
ExternalMask=[];
% Now override defaults with FlagStructure

clear j


if nargin==1
    expandstructure(FlagStructure)  %Cheating with matlab.  step through with
    %debugger to understand.
end

N  =ClimateSpaceN;
Rev=ClimateSpaceRev;

%%% Preliminaries

% Get Area per grid cell
[Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;
[Lat2d,Long2d]=meshgrid(Lat,Long);


potentialyield=NaN*ones(size(FiveMinGridCellAreas));

AllIndices=1:9331200;

%% Don't allow for BoxPlot or Bin PLots if ibinlist is 0
if ibinlist==0
    if MakeBoxPlot==1
        disp('turning off BoxPlots')
        MakeBoxPlot=0;
    end
    if MakeBinPlots==1
        disp('turning off Bin Plots')
        MakeBinPlots=0;
    end
end

%%% Read from crops.csv
[DS,NS]=CSV_to_structure('crops.csv');

%for j=1:length(NS.col1);

j=CropNo;
%%%%%%%% Crop specific
cropname=NS.col1{j};
cropfilename=NS.col2{j};
croppath=NS.col3{j};
suitpath=NS.col4{j};
suitbins=NS.col5(j);
cropconv=NS.col6(j);
areafilter=NS.col7(j);

systemglobals
croppath=[IoneDataDir '/Crops2000/crops/' croppath];

if QuietFlag==0
    disp(['Working on ' cropname]);
end

%% read in crop netCDF file, extract area fraction.
CropData=OpenNetCDF(croppath);
AreaFraction=CropData.Data(:,:,1);
AreaFraction(AreaFraction>1e10)=NaN;

Yield=CropData.Data(:,:,2);
clear CropData
%cropname=strrep(cropname,' ','_');
CultivatedArea=AreaFraction.*FiveMinGridCellAreas;
Production=CultivatedArea.*Yield;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Climate Mask



%% find GDD Temp
a=DS.Suitability{j};
GDDTempstr=a(end-6);
Nstr=int2str(N);
switch Rev
    case {'F','H'}
ClimateMaskFile=['ClimateMask_' cropname '_' HeatFlag GDDTempstr '_'  ...
    WetFlag '_' int2str(N) 'x' int2str(N) '_Rev' Rev];

    case 'G'
ClimateMaskFile=['ClimateMask_' cropname '_' HeatFlag GDDTempstr '_'  ...
    WetFlag '_' int2str(N) 'x' int2str(N) '_Rev' Rev  ... 
    '_soilrev' csqirev];

    otherwise
        error
end


if QuietFlag==0
    disp(['Loading ClimateLibraryDir/' ClimateMaskFile]);
end
load([ClimateLibraryDir '/' ClimateMaskFile]);

ClimateMask=BinMatrix;

if DistributionOfAreaPlotFlag==1;
    DistributionOfAreaPlot;
end


%%% Calculate 5% of bin areas.  only care about areas with Yield Data.

ii= isfinite(Production) & Yield < 1e10 & Yield>0;

AreaValues=CultivatedArea(ii);
AVsort=sort(AreaValues);
cumulativeAV=cumsum(AVsort);
cAVnorm=cumulativeAV/max(cumulativeAV);
[iiAV]=min(find(cAVnorm>=.05));
FifthPercentileArea=AVsort( iiAV);
[iiAV]=min(find(cAVnorm>=.01));
FirstPercentileArea=AVsort( iiAV);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Have now set up
%matrices, can loop over bins and look at each bin individually and
%get yield gaps.


YieldGapArray=NaN*ones(size(Yield));
UnfilteredYGA=NaN*ones(size(Yield));
AllBinsYieldGapArray=NaN*ones(size(Yield));

if ibinlist==0
    ListOfBins=unique(ClimateMask);
    ListOfBins=ListOfBins(ListOfBins>0);  %don't want zero
else
    ListOfBins=ibinlist;
end



if OutputBinDQ==1
    fid=fopen([BinDQFileName '_' cropname '.csv'],'w');
end



% Initialize MedianYield
MedianYield=NaN*ones(1,N^2);
TotalYield=NaN*ones(1,N^2);
TotalArea=NaN*ones(1,N^2);

clear TotalAreaPerBin NumDataPointsPerBin
if QuietFlag==0
    disp(['Working through' int2str(length(ListOfBins)) ' bins.']);
end


LogicalArrayOfGridPointsInABin=logical(zeros(size(Yield)));

for ibin=ListOfBins(:)';
    if QuietFlag==0
        disp(' ')
        disp(['Calculating yield gap for bin # ' int2str(ibin) ...
            ' (' ClimateDefs{ibin} ')']);
    end
    
    
    %InitializeSomeVariables
    Yield90=-1;
    Yield50=-1;
    
    
    %%% SECTION TO LIMIT BINS.  First we limit datapoints in the bin
    %%% (i.e. because of area of a particular datapoint is too small.)
    %%% next, we will decide if we are going to throw out the entire
    %%% climate bin  (i.e. because there are too few datapoints in the
    %%% bin)
    
    % limit bins to finite data, and this climate bin.
    iiGood=(DataMaskLogical & Yield < 1e10 & isfinite(Yield));
    
    
    if isempty(ExternalMask);
            iiGood=(DataMaskLogical & Yield < 1e10 & isfinite(Yield));
    else
        if ~islogical(ExternalMask) 
            error('ExternalMask not logical')
        end
        iiGood=(DataMaskLogical & Yield < 1e10 & isfinite(Yield) & ExternalMask);
    end
    
    
    BinFilter=(ClimateMask==ibin & iiGood);
    
    
    
    % limit individual bins based on area.
    
    switch IndividualAreaMethod
        case 'none'
            IndicesToKeep=(BinFilter  );
        case 'fixed'
            IndicesToKeep=( BinFilter  & CultivatedArea >= areafilter);
        case 'AllBinFifthPercentile'
            IndicesToKeep=( BinFilter  & CultivatedArea >= FifthPercentileArea);
        case 'NathansOmegaFueledBrainChild'
            
        otherwise
            error('don''t know how to filter area this way')
            
    end
    
    
    AllBinIndices=( BinFilter  & CultivatedArea >= FirstPercentileArea);;
    
    
    
    % Now we have our binfilter (i.e. those points which are in the bin
    % and have appropriate area characteristics)
    
    
    AreaCol=CultivatedArea(IndicesToKeep);
    ProductionCol=Production(IndicesToKeep);
    YieldCol=Yield(IndicesToKeep);
    BinFilteredIndices=AllIndices(IndicesToKeep);
    LatCol=Lat2d(IndicesToKeep);
    LongCol=Long2d(IndicesToKeep);
    
    LogicalArrayOfGridPointsInABin=(LogicalArrayOfGridPointsInABin | ...
        IndicesToKeep);
    
    IndicesToKeep=find(IndicesToKeep);
    
    
    %
    AllBinYieldCol=Yield(AllBinIndices);
    
    % make vectors of
    
    TotalAreaPerBin(ibin)=sum(CultivatedArea(IndicesToKeep));
    
    NumDataPointsPerBin(ibin)=length(IndicesToKeep);
    
    
    
    %% Minimum number of grid cells
    PassMinNumber=1;
    PassMinNumberSummary=['Num Bins = ' int2str(length(IndicesToKeep)) '. (Min=' int2str(MinNumberPointsPerBin) ')'];
    PassMinNumberSummaryNoText=[ int2str(length(IndicesToKeep)) ',' int2str(MinNumberPointsPerBin)];
    
    if length(IndicesToKeep)<MinNumberPointsPerBin
        PassMinNumber=0;
    end
    
    %% Minumum number of unique yield values
    PassMinNumYieldValues=1;
    PassMinNumYieldValuesSummary=['Num Yield Values = ' int2str(length(unique(YieldCol))) '. (Min=' int2str(MinNumberYieldValues) ')'];
    PassMinNumYieldValuesSummaryNoText=[ int2str(length(unique(YieldCol))) ',' int2str(MinNumberYieldValues)];
    
    if length(unique(YieldCol))<MinNumberYieldValues
        PassMinNumYieldValues=0;
    end
    
    %% Minumum number of unique yield values
    PassMinNumHectares=1;
    PassMinNumberHectaresSummary=['Num Bins = ' int2str(sum(AreaCol)) '. (Min=' int2str(MinNumberHectares) ')'];
    PassMinNumberHectaresSummaryNoText=[ int2str(sum(AreaCol)) ',' int2str(MinNumberHectares)];
    if sum(AreaCol)<MinNumberHectares
        PassMinNumHectares=0;
    end
    
    
    %% write out information for this bin:
    
    %        if ~PassMinNumHectares;   disp(['MinNumHecatres=' int2str(sum(AreaCol)) ]); end;
    %        if ~PassMinNumYieldValues;   disp(['Num Unique Yield Vals=' int2str(length(unique(YieldCol))) ]); end;
    %        if ~PassMinNumber;   disp(['Num Bins=' int2str(length(IndicesToKeep)) ]); end;
    
    if ~PassMinNumHectares;   disp(PassMinNumberHectaresSummary); end;
    if ~PassMinNumYieldValues;   disp(PassMinNumYieldValuesSummary); end;
    if ~PassMinNumber;   disp(PassMinNumberSummary); end;
    
    if (PassMinNumber & PassMinNumYieldValues & PassMinNumHectares)
        CropTable=[YieldCol AreaCol ProductionCol];
        
        IndexYieldColumn = 1;
        IndexAreaColumn = 2;
        IndexProductionColumn = 3;
        
        FilteredCropTable=CropTable(:,1:3);
        FilteredLong=LongCol(:);
        FilteredLat=LatCol(:);
        FilteredIndices=BinFilteredIndices(:);
        
        if MakeBinPlots==1
            NewYieldGapBinPlots
        end;  %end of plotting section
        
        
        
        %% Section to derive "90th %" yield
        
        fct=FilteredCropTable;
        [dum,ii]=sort(fct(:,1));
        fct=fct(ii,1:3);
        
        yield=fct(:,1);
        area=fct(:,2);
        production=fct(:,3);
        
        total_area = sum(fct(:,2));
        total_prod = sum(fct(:,3));
        ave_yield = total_prod ./ total_area;
        
        cum_prod = cumsum(fct(:,3));
        fct(:,4) = cum_prod;
        cum_area = cumsum(fct(:,2));
        fct(:,5) = cum_area;
        cum_percarea = ((fct(:,5))./ total_area) * 100;
        fct(:,6) = cum_percarea;
        
        
        n=PercentileForMaxYield;
        %%% This gives the ii that leads to Rachel and Matt method
        %%% (i.e. closest to 90)
        [dummyvalue,ii] = min(abs(fct(:,6)-n));
        
        %%% This gives the Nathan and JG method (i.e. smallest that is
        %%% >=90)
        %     [ii] = min(find(fct(:,6)>n));
        
        %temp.row=[temp.row fct(end,1)]
        
        
        Yield90=fct(ii,1);
        
        
        % find median yields for the joint distribution plots
        n=50;
        [dummyvalue,ii] = min(abs(fct(:,6)-n));
        Yield50=fct(ii,1);
        MedianYield(ibin) = Yield50;
        TotalArea(ibin)=fct(end,5);
        
        
        
        %% want weighted yields
        production=FilteredCropTable(:,IndexProductionColumn);
        FilteredYield=FilteredCropTable(:,IndexYieldColumn);
        
        x=sort(production);
        Production90=x(round(length(x)*.90));
        
        ii90=find(production<=Production90);
        
        
        
        
        
        YieldGap=max(1-FilteredYield/Yield90,0);
        UnfilteredYieldGap=(1-FilteredYield);
        %now pack back into relative yield array
        
        YieldGapArray(FilteredIndices)=YieldGap;
        UnfilteredYGA(FilteredIndices)=UnfilteredYieldGap;
        
        %%
        %            potentialyield(
        iihighyield= BinFilter & Yield >= Yield90;
        iilowyield=find(BinFilter & Yield < Yield90);
        potentialyield(iilowyield)=Yield90; %not necessarily 90.
        %potentialyield(iihighyield)=Yield(iihighyield); %not necessarily 90.
        potentialyield(iihighyield)=Yield90;
        PassFail='PASS: ';
        
        
        %  AllPoints
        tmp=Yield(AllBinIndices);
        tmpyieldgap=(1-tmp./Yield90);
        tmpyieldgap=max(0,tmpyieldgap);
        AllBinsYieldGapArray(AllBinIndices)=tmpyieldgap;
        
    else
        disp(['ibin=' num2str(ibin) ' Did not pass data quality tests:']);
        if ~PassMinNumHectares;   disp(['MinNumHecatres=' int2str(sum(AreaCol)) ]); end;
        if ~PassMinNumYieldValues;   disp(['Num Unique Yield Vals=' int2str(length(unique(YieldCol))) ]); end;
        if ~PassMinNumber;   disp(['Num Bins=' int2str(length(IndicesToKeep)) ]); end;
        disp(['Climate Bin Info: ' ClimateDefs{ibin} ])
        disp('')
        PassFail='FAIL: ';
    end %end of pass data quality tests.
    
    %   fprintf(fid,'%s,%s,%s\n',PassMinNumberSummaryNoText,PassMinNumYieldValuesSummaryNoText,PassMinNumberHectaresSummaryNoText);
    if OutputBinDQ==1
        fprintf(fid,'%s,%s,%s,%s,%s\n',PassFail,ClimateDefs{ibin},PassMinNumberSummary,PassMinNumYieldValuesSummary,PassMinNumberHectaresSummary);
    end
    
    
    VectorOfPotentialYields(ibin)=Yield90;
    
    
end
if OutputBinDQ==1
    fclose(fid);
end

if SurfacePlotOfAreaInClimateSpaceFlag==1
    
    if isequal(Rev,'E') | isequal(Rev,'F')
        PatchPlotOfAreaInClimateSpace;
    else
        SurfacePlotOfAreaInClimateSpace;
    end
    
    clear x y z
end



if MakeAllBinsBoxPlot==1
    %%% now box plot of everything
    AllBinsBoxPlot
end

if MakeGlobalMaps==1
    MakeGlobalMapsScript
end

if MakeGlobalMapsSoil==1
    MakeGlobalMapsScriptSoil
end

if PredictYieldPlots==1
    PredictYieldRegressionPlots;
end
if MakePotentialYieldMapFlag>0
    MakePotentialYieldMap;
end

if PointsPerBinPlotsFlag==1;
    figure
    subplot(211)
    plot(ListOfBins,NumDataPointsPerBin,'x')
    xlabel('Bin Number')
    title([cropname '. Number of datapoints per bin. ' WetFlag])
    ylabel('Number datapoints per bin')
    grid on
    
    subplot(212)
    plot(ListOfBins,TotalAreaPerBin/1e3,'x')
    xlabel('Bin Number')
    title([cropname '. Total area per bin. ' WetFlag])
    ylabel('kha')
    grid on
    fattenplot
    OutputFig('Force')
end

if MakeBinWeightedYieldGapPlotFlag==1;
    
    Outline=CountryNameToOutline('Ukraine');
    Bins=unique(BinMatrix(find(Outline==1)));
    jj=logical(BinMatrix*0);
    for k=1:length(Bins)
        jj=(jj | BinMatrix==Bins(k));
    end
    Weight=jj*0;
    Weight(jj)=1;
    % BrightnessPlot(Long,Lat,YieldGapArray,Weight);
    WinterAddRedPlot(Long,Lat,YieldGapArray,Weight);
end

OutputStructure.Yield=Yield;
OutputStructure.YieldGapFraction=single(YieldGapArray);
OutputStructure.potentialyield=single(potentialyield);
OutputStructure.ClimateMask=int8(ClimateMask);
OutputStructure.ClimateMaskFile=ClimateMaskFile;
OutputStructure.Area=CultivatedArea;
OutputStructure.cropname=cropname;
OutputStructure.ClimateDefs=ClimateDefs;
OutputStructure.CDS=CDS;
OutputStructure.MaxYield=Yield90;
OutputStructure.VectorOfPotentialYields=VectorOfPotentialYields;
OutputStructure.LogicalArrayOfGridPointsInABin=...
    LogicalArrayOfGridPointsInABin;
OutputStructure.InputStructureRecord=FlagStructure;
OutputStructure.Top99YieldGapFraction=AllBinsYieldGapArray;
[RevNo,RevString,LastChangeRevNo,LCRString,AI]=GetSVNInfo;
RevData.CodeRevisionNo=RevNo;
RevData.CodeRevisionString=RevString;
RevData.LastChangeRevNo=LastChangeRevNo;
RevData.ProcessingDate=datestr(now);
OutputStructure.RevData=RevData;
FS=FlagStructure;
OS=OutputStructure;
save(FileName,'FS','OS');


