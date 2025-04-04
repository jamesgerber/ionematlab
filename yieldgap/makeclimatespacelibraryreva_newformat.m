clear DAS
for N=[10]
    for jcrop=[5] 
        for jwf=2;
            for jhf=1
            
            
            
            
            %Rev B settings:
            PercentToDrop=5;  % "5" to force a 5% of cultivated area bin at top and bottom
            
            %% Get crop information section
            [Long,Lat,FiveMinGridCellAreas]=OpenNetCDF(['/Users/jsgerber/sandbox/jsg003_YieldGapWork/' ...
                'YieldGap/area_ha_5min.nc']);
            
            [DS,NS]=CSV_to_structure('../YieldGap/crops.csv');
            
            %for j=1:length(NS.col1);
            %%%%%%%% Crop specific
            j=jcrop;
            cropname=NS.col1{j};
            cropfilename=NS.col2{j};
            croppath=NS.col3{j};
            suitpath=NS.col4{j};
            suitbins=NS.col5(j);
            cropconv=NS.col6(j);
            areafilter=NS.col7(j);
            
            cropname=strrep(cropname,' ','_');
            %% read in crop netCDF file, extract area fraction.
            CropData=OpenNetCDF(croppath);
            AreaFraction=CropData.Data(:,:,1);
            AreaFraction(find(AreaFraction>1e10))=NaN;
            
            a=DS.Suitability{j};
            GDDTempstr=a(end-6);
            
            Yield=CropData.Data(:,:,2);
            clear CropData
            
            CultivatedArea=AreaFraction.*FiveMinGridCellAreas;
            Production=CultivatedArea.*Yield;
            
            [Long,Lat,WorldClimprec]=OpenNetCDF('/Library/IonE/data/Climate/WorldClim_5min_prec.nc');
            WorldClimprec=sum(WorldClimprec,4);
            
            switch jwf
                case 1
                    WetFlag='prec_on_gdd'
                case 2
                    WetFlag='prec'
                case 3
                    WetFlag='aei'
            end
            
            
            switch jhf
                case 1
                    HeatFlag='GDD'
                case 2
                    HeatFlag='GSL'
            end
            
            
       
            [Long,Lat,Heat]=OpenNetCDF(['~jsgerber/sandbox/jsg003_YieldGapWork/' ...
                'GDDLibrary/' HeatFlag GDDTempstr '.nc']);
            
            switch WetFlag
                case 'prec_on_gdd'
                    [Long,Lat,PrecOnGDD]=OpenNetCDF(['/Users/jsgerber/sandbox/jsg003_YieldGapWork/GDDLibrary/PrecWhenGDD' ...
                        GDDTempstr '.nc']);
                    Prec=PrecOnGDD;
                          x=linspace(0,3000,N+1);
PrecBinEdges=[x(1:end-1) 10000];
                case 'prec'
                    Prec=WorldClimprec;
                     x=linspace(0,3000,N+1);
    PrecBinEdges=[x(1:end-1) 10000];
                case 'aei'
                    [Long,Lat,aei]=OpenNetCDF(['/Users/jsgerber/sandbox/' ...
                        'jsg003_YieldGapWork/5min_aei.nc']);
                    Prec=aei;
                     x=linspace(0,1,N+1);
          PrecBinEdges=[x(1:end-1) 1];
                otherwise
                    error
            end
            
            switch HeatFlag
          %      case 'GSL'
          %          eval('Heat=GSL;');
                case 'GDD'
                    eval('GDD=Heat;');
                otherwise
                    error
            end
            x=linspace(0,10000,N+1);
GDDBinEdges=[x(1:end-1) 13000];
            
            
            
            %% Make bins
        %    [GDDBinEdges,PrecBinEdges]= ...
        %        CalculateBins_EqualAreaSpace(Heat,Prec,CultivatedArea,N,PercentToDrop);
       %      [GDDBinEdges,PrecBinEdges]= ...
       %         CalculateBins_CenteredSpace(Heat,Prec,CultivatedArea,N,PercentToDrop);
        
            PrecBinEdges
            GDDBinEdges
            %[BinMatrix,GDDBins,PrecBins,ClimateDefs]=MakeClimateSpace(GDD,Prec,GDDBinEdges,PrecBinEdges);
            [BinMatrix,PrecBins,GDDBins,ClimateDefs]=MakeClimateSpace(Prec,Heat,PrecBinEdges,GDDBinEdges);
            BinMatrix=single(BinMatrix);
            FileName=['ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(length(GDDBinEdges)-1) ...
                'x' int2str(length(PrecBinEdges)-1) '_RevA'];
            
            
            save(FileName,'BinMatrix','GDDBins','PrecBins','ClimateDefs','GDDBinEdges','PrecBinEdges','Prec','GDD',...
                'PercentToDrop','WetFlag','HeatFlag','CultivatedArea');
            DAS.Description='Climate Space Library, Revision A.  October 22, 2009';
            WriteNetCDF(Long,Lat,single(BinMatrix),'ClimateMask',[FileName '.nc'],DAS);
            end
        end
    end
end