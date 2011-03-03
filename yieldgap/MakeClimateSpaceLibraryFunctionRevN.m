function MakeClimateSpaceLibraryFunctionRevN(FlagStructure)
%% MakeClimateSpaceLibraryFunctionRevN   New Yield Gap Work - J. Gerber, N. Mueller
%
%  SYNTAX
%      YieldGapFunction  Will compute yield gaps according to
%      default settings.
%
%
%  Example
%
%  FS.SaveFileNameBaseDir='ClimateLibrary';
%  FS.jcropvector=[5 7];
%  FS.Nspace=[5 10];
%  FS.GDDBaseDir='GDDLibrary/'
%  FS.TMILocation='./TMI.mat';
%  FS.GetBinsElsewhere='../Climate0/ClimateLibrary/';
% OutputStructure=MakeClimateSpaceLibraryFunctionRevN(FS);
%
%
%
% Get crop information section

Rev='N';


jcropvector=[5 7];
Nspace=[5 10];
GDDBaseDir='GDDLibrary/';
TMILocation='./TMI.mat';
AnnualMeanPrec='./AnnualMeanPrec.mat';
SaveFileNameBaseDir='./ClimateLibrary';
GetBinsElsewhere='';
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

for N=Nspace;
    for jcrop=jcropvector
        for   jwf=[2];
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
                'x' int2str(N) '_RevN'];
            
            NoBaseFileName=['/ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
                'x' int2str(N) '_RevN'];
            
            if exist([FileName '.nc'])==2
                disp(['Already have ' FileName '.nc'])
            else
                [Long,Lat,Heat]=OpenNetCDF([GDDBaseDir ...
                    HeatFlag GDDTempstr '.nc']);
                
                switch WetFlag
                    case 'TMI'
                        load([TMILocation]);
                        Prec=TMI;
                    case 'prec'
                        load([AnnualMeanPrec]);
                        Prec=annualmeanprec;
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
                    % Make bins
                    
                    % RevN - if Cultivated Area ==0, then do not take those
                    % bins into account when calculating Bin Edges.
                    
                    tempvar=Heat;
                    ii=(CultivatedArea==0);
                    tempvar(ii)=1e20;  % this will cause these guys to be ignored
                    
                    [PrecBinEdges,GDDBinEdges,xbins,ybins,ContourMask,InsideContourLogical]= ...
                        CalculateBins_Globally_RevN(Prec,tempvar,...
                        CultivatedArea,N,300,PercentToDrop,cropname,WetFlag,HeatFlag);
                    
                    
                    %  PrecBinEdges
                    %  GDDBinEdges
                    
                    if iscell(PrecBinEdges);
                        NP=length(PrecBinEdges);
                    else
                        NP=length(PrecBinEdges)-1
                    end
                    if iscell(GDDBinEdges);
                        NG=length(GDDBinEdges);
                    else
                        NG=length(GDDBinEdges)-1
                    end
                    
                    [BinMatrix,PrecBins,GDDBins,ClimateDefs,CDS]=MakeClimateSpace(Heat,Prec,GDDBinEdges,PrecBinEdges);
                    BinMatrix=single(BinMatrix);
                    
               %     % now need to refine CDS
               %     disp('refining bins')
               %     [CDSnew]=...
               %         RefineClimateSpaceRevN(Heat,Prec,CultivatedArea,CDS,xbins,ybins,ContourMask,[cropname ' ' WetFlag]);
                    
               %     %% Make Climate Space
                    
               %     CDS=CDSnew;
                else
                    %% Get bins from somewhere else
                    disp(['Getting Bins from ' GetBinsElsewhere]);
                    load([GetBinsElsewhere filesep NoBaseFileName],'CDS','InsideContourLogical');
                end
                
                [BinMatrix,ClimateDefs]=...
                    ClimateDataStructureToClimateBins(CDS,Heat,Prec,CultivatedArea,HeatFlag,WetFlag,InsideContourLogical);

                
                %%
                %Now can make a plot
                
                MultiBoxPlotInClimateSpace(CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,InsideContourLogical);
                
                %%
                save(FileName,'BinMatrix','ClimateDefs','Prec','GDD',...
                    'PercentToDrop','WetFlag','HeatFlag','CultivatedArea',...
                    'CDS','InsideContourLogical','GDDTempstr');
                DAS.Description=['Climate Space Library, Revision ' Rev '. ' datestr(now)];
                WriteNetCDF(Long,Lat,single(BinMatrix),'ClimateMask',[FileName '.nc'],DAS);
            end
            close all
        end
        
    end
    
end