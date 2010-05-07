function MakeClimateSpaceLibraryFunctionRevG(FlagStructure)
%% MakeClimateSpaceLibraryFunctionRevG   New Yield Gap Work - J. Gerber, N. Mueller
%
%  SYNTAX
%      YieldGapFunction  Will compute yield gaps according to
%      default settings.
%
%
%  Example
%
%  FS.SaveFileNameBaseDir='ClimateLibrary3D';
%  FS.jcropvector=[13 5 17 9 7];
%  FS.Nspace=[5 ];
%  FS.GDDBaseDir='GDDLibrary/'
%  FS.TMILocation='./TMI.mat';
%  FS.GetBinsElsewhere='ClimateSpaces';
%  FS.csqirev='Ar2';
%  MakeClimateSpaceLibraryFunctionRevG(FS);
%
%
%
% Get crop information section


jcropvector=[13 5 17 9 7];
Nspace=[5];
GDDBaseDir='GDDLibrary/';
TMILocation='./TMI.mat';
SaveFileNameBaseDir='./ClimateLibrary';
GetBinsElsewhere='';
csqirev='Ar2';
if nargin==1
    expandstructure(FlagStructure)  %Cheating with matlab.  step through with
    %debugger to understand.
end

try
    ls(SaveFileNameBaseDir)
catch
    error(['can''t find directory ' SaveFileNameBaseDir])
end

[Long,Lat,FiveMinGridCellAreas]=GetFiveMinGridCellAreas;

try
    [Long,Lat,cSQI]=getdata(['HWSD_CategoricalCSQI_' csqirev]);
catch
    error(['problem loading Categorical Soil types']);
end

for N=Nspace;
    for jcrop=jcropvector
        jwf=4;
        jhf=1
        
        %Rev B settings:
        PercentToDrop=0;  % "5" to force a 5% of cultivated area bin at top and bottom
        
        
        
        %%% Read from crops.csv
        [DS,NS]=CSV_to_structure('crops.csv');
        
        %for j=1:length(NS.col1);
        j=jcrop;
        
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
        
        
        disp(['Working on ' cropname]);
        
        
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
        
        FileName=[SaveFileNameBaseDir '/ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
            'x' int2str(N) '_RevG' '_soilrev' csqirev];
        
        NoBaseFileName=['/ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
            'x' int2str(N) '_RevG'];
        
        if (exist([FileName '.nc'])==2 & exist([FileName '.mat'])==2)
            disp(['Already have ' FileName '.nc'])
        else
            [Long,Lat,Heat]=OpenNetCDF(['~jsgerber/sandbox/jsg003_YieldGapWork/' ...
                'GDDLibrary/' HeatFlag GDDTempstr '.nc']);
            
            switch WetFlag
                case 'TMI'
                    load([TMILocation]);
                    Prec=TMI;
                otherwise
                    error(['Don''t have ability to handle' WetFlag ' in ' mfilename ]);
            end
            
            switch HeatFlag
                %      case 'GSL'
                %          eval('Heat=GSL;');
                case 'GDD'
                    eval('GDD=Heat;');
                otherwise
                    error(['Don''t have ability to handle' HeatFlag ' in ' mfilename ]);
            end
            
            
            
            
            if isempty(GetBinsElsewhere)
                disp(['Making bins'])
                %% Make bins
                [PrecBinEdges,GDDBinEdges]= ...
                    CalculateBins_GloballyEqualAreaSpace(Prec,Heat,CultivatedArea,N,PercentToDrop);
            else
                %% Get bins from somewhere else
                disp(['Getting Bins from ' GetBinsElsewhere]);
                load([GetBinsElsewhere filesep NoBaseFileName],'PrecBinEdges','GDDBinEdges');
            end
            
            %  PrecBinEdges
            %  GDDBinEdges
            
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
            [BinMatrix,PrecBins,GDDBins,ClimateDefs,CDS]=...
                MakeClimateSpace3rdCategory(Prec,Heat,PrecBinEdges,GDDBinEdges,cSQI,[1:3]);
            BinMatrix=single(BinMatrix);
            
            
            
            save(FileName,'BinMatrix','GDDBins','PrecBins','ClimateDefs','GDDBinEdges','PrecBinEdges','Prec','GDD',...
                'PercentToDrop','WetFlag','HeatFlag','CultivatedArea','CDS','csqirev');
            DAS.Description=['Climate Space Library, Revision G. ' datestr(now)];
            WriteNetCDF(Long,Lat,single(BinMatrix),'ClimateMask',[FileName '.nc'],DAS);
        end
    end
end