clear DAS
for N=[1]
    for jcrop=[7]
        for jwf=4;
            for jhf=1
            
            
            
            
            %Rev B settings:
            PercentToDrop=0;  % "5" to force a 5% of cultivated area bin at top and bottom
            
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
                case 4
                    WetFlag='TMI'
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
                case 'prec'
                    Prec=WorldClimprec;
                case 'aei'
                    [Long,Lat,aei]=OpenNetCDF(['/Users/jsgerber/sandbox/' ...
                        'jsg003_YieldGapWork/5min_aei.nc']);
                    Prec=aei;
                case 'TMI'
                    load '/Users/jsgerber/sandbox/jsg003_YieldGapWork/TMI.mat';
                    Prec=TMI;
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
            
            
            
            
            %% Make bins
            [PrecBinEdges,GDDBinEdges]= ...
                CalculateBins_GloballyEqualAreaSpace(Prec,Heat,CultivatedArea,N,PercentToDrop);
            
            PrecBinEdges
            GDDBinEdges

            if iscell(PrecBinEdges);
                NP=length(PrecBinEdges)
            else
                NP=length(PrecBinEdges)-1
            end
            if iscell(GDDBinEdges);
                NG=length(GDDBinEdges)
            else
                NG=length(GDDBinEdges)-1
            end          
            %[BinMatrix,GDDBins,PrecBins,ClimateDefs]=MakeClimateSpace(GDD,Prec,GDDBinEdges,PrecBinEdges);
            [BinMatrix,PrecBins,GDDBins,ClimateDefs,CDS]=MakeClimateSpace(Prec,Heat,PrecBinEdges,GDDBinEdges);
            BinMatrix=single(BinMatrix);
            FileName=['ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(NG) ...
                'x' int2str(NP) '_RevF'];
            
            
            save(FileName,'BinMatrix','GDDBins','PrecBins','ClimateDefs','GDDBinEdges','PrecBinEdges','Prec','GDD',...
                'PercentToDrop','WetFlag','HeatFlag','CultivatedArea','CDS');
            DAS.Description='Climate Space Library, Revision F.  November 2, 2009';
            WriteNetCDF(Long,Lat,single(BinMatrix),'ClimateMask',[FileName '.nc'],DAS);
            end
        end
    end
end