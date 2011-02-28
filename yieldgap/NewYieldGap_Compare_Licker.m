
%% New Yield Gap Work - J. Gerber, N. Mueller


%% Set Flags
ApplyAreaFilterFlag=1;

MinNumberPointsPerBin=1;
MinNumberHectares=1;
MinNumberCountries=0;  % this doesn't actually do anything
MinNumberYieldValues=5;

OutputBinDQ=1;
BinDQFileName='BinDataQuality';

%IndividualAreaMethod='AllBinFifthPercentile';
IndividualAreaMethod='fixed';



RachelClimateMask=1;
MakeBoxPlot=0;
MakeBinPlots=0;
MakeAllBinsBoxPlot=0;
MinNumPointsAllBinsBoxPlot=200;
ibinlist=0;   %if 0, do all bins.
MakeGlobalMaps=1;

%%% Preliminaries

% Get Area per grid cell (sort of silly ... should probably just put
% analytical expression into a function)

[Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;
[Lat2d,Long2d]=meshgrid(Lat,Long);

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
%%%%%%%% Crop specific
for j=5
    cropname=NS.col1{j};
    cropfilename=NS.col2{j};
    croppath=NS.col3{j};
    suitpath=NS.col4{j};
    suitbins=NS.col5(j);
    cropconv=NS.col6(j);
    areafilter=NS.col7(j);
    
    %% read in crop netCDF file, extract area fraction.
    CropData=OpenNetCDF(croppath);
    AreaFraction=CropData.Data(:,:,1);
    AreaFraction(find(AreaFraction>1e10))=NaN;
    
    Yield=CropData.Data(:,:,2);
    clear CropData
    
    CultivatedArea=AreaFraction.*FiveMinGridCellAreas;
    Production=CultivatedArea.*Yield;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Climate Mask
    
    
    if RachelClimateMask==1
        disp(['loading ' suitpath]);
        [Long,Lat,ClimateMask]=OpenNetCDF(suitpath);
        for m=1:100
            ClimateDefs{m}=['bin ' int2str(m)];
        end
        Nstr='10';
        WetFlag='aei';
        a=DS.Suitability{j};
        GDDTempstr=a(end-6);
    else
        %% find GDD Temp
        a=DS.Suitability{j};
        GDDTempstr=a(end-6);
        
        [Long,Lat,GDD]=OpenNetCDF(['~jsgerber/sandbox/jsg003_YieldGapWork/' ...
            'GDDCode/GDD' GDDTempstr '.nc']);
        
        [Long,Lat,Prec]=OpenNetCDF(['/Users/jsgerber/sandbox/jsg003_YieldGapWork/GDDCode/PrecWhenGDD' ...
            GDDTempstr '.nc']);
        %      NumBins=10;
        %      GDDBinEdges=SelectUniformBins(GDD8(DataMaskIndices),NumBins);
        %      PrecBinEdges=SelectUniformBins(Prec(DataMaskIndices),NumBins);
        disp(['Making Space of climate bins'])
        tic
        [BinMatrix,GDDBins,PrecBins,ClimateDefs]=MakeClimateSpace(GDD,Prec,GDDBinEdges,PrecBinEdges);
        %       [BinMatrix2,GDDBins2,PrecBins2,ClimateDefs2]=MakeClimateSpaceVectorized(GDD,Prec,GDDBinEdges,PrecBinEdges);
        ClimateMask=BinMatrix;
        toc
    end
    
    
    %%% Calculate 5% of bin areas.  only care about areas with Yield Data.
    
    ii=find(isfinite(Production) & Yield < 1e10 & Yield>0);
    
    AreaValues=CultivatedArea(ii);
    AVsort=sort(AreaValues);
    FifthPercentileArea=AVsort( round(length(AVsort)*.05));
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Have now set up
    %matrices, can loop over bins and look at each bin individually and
    %get yield gaps.
    
    
    YieldGapArray=NaN*ones(size(Yield));
    UnfilteredYGA=NaN*ones(size(Yield));
    
    if ibinlist==0
        ListOfBins=unique(ClimateMask);
        ListOfBins=ListOfBins(ListOfBins>0);  %don't want zero
    else
        ListOfBins=ibinlist;
    end
    
    
    
    if OutputBinDQ==1
        fid=fopen([BinDQFileName '_' cropname '.csv'],'w');
    end
    
    
    
    
    
    
    disp(['Working through' int2str(length(ListOfBins)) ' bins.']);
    for ibin=ListOfBins(:)';
        disp(' ')
        disp(['Calculating yield gap for bin # ' int2str(ibin)]);
        
        %%% SECTION TO LIMIT BINS.  First we limit datapoints in the bin
        %%% (i.e. because of area of a particular datapoint is too small.)
        %%% next, we will decide if we are going to throw out the entire
        %%% climate bin  (i.e. because there are too few datapoints in the
        %%% bin)
        
        % limit bins to finite data, and this climate bin.
        iiGood=(DataMaskLogical & Yield < 1e10 & isfinite(Yield));
        
        BinFilter=(ClimateMask==ibin & iiGood);
        
        % limit individual bins based on area.
        
        switch IndividualAreaMethod
            case 'none'
                IndicesToKeep=find(BinFilter  );
            case 'fixed'
                IndicesToKeep=find( BinFilter  & CultivatedArea >= areafilter);
            case 'AllBinFifthPercentile'
                IndicesToKeep=find( BinFilter  & CultivatedArea >= FifthPercentileArea);
            case 'NathansOmegaFueledBrainChild'
                
            otherwise
                error('don''t know how to filter area this way')
                
        end
        
        
        % Now we have our binfilter (i.e. those points which are in the bin
        % and have appropriate area characteristics)
        
        
        AreaCol=CultivatedArea(IndicesToKeep);
        ProductionCol=Production(IndicesToKeep);
        YieldCol=Yield(IndicesToKeep);
        BinFilteredIndices=AllIndices(IndicesToKeep);
        LatCol=Lat2d(IndicesToKeep);
        LongCol=Long2d(IndicesToKeep);
        
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
            
            
            n=90;
            %%% This gives the ii that leads to Rachel and Matt method
            %%% (i.e. closest to 90)
            [dummyvalue,ii] = min(abs(fct(:,6)-n));
            
            %%% This gives the Nathan and JG method (i.e. smallest that is
            %%% >=90)
       %     [ii] = min(find(fct(:,6)>n));
            
            %temp.row=[temp.row fct(end,1)]
            
            
            Yield90=fct(ii,1);
            
            
            
            
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
            
            PassFail='PASS: ';
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
        fprintf(fid,'%s,%s,%s,%s,%s\n',PassFail,ClimateDefs{ibin},PassMinNumberSummary,PassMinNumYieldValuesSummary,PassMinNumberHectaresSummary);
        
        
        
    end
    
    fclose(fid);
    
    if MakeAllBinsBoxPlot==1
        %%% now box plot of everything
        AllBinsBoxPlot
    end
    
    if MakeGlobalMaps==1
        MakeGlobalMapsScript
    end
    
    
    
    titlestr=(['Yield Gap for ' cropname ]);
    
end

