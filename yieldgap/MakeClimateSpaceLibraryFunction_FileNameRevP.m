function MakeClimateSpaceLibraryFunctionRevP(FlagStructure)
%% MakeClimateSpaceLibraryFunctionRevP   New Yield Gap Work - J. Gerber, N. Mueller
%
%  SYNTAX
%      YieldGapFunction  Will compute yield gaps according to
%      default settings.
%
%
%  Example
%
%  FS.SaveFileNameBaseDir='ClimateLibrary';
%  FS.CropNames={'maize','wheat'};
%  FS.Nspace=[5 10];
%  FS.GDDBaseDir='GDDLibrary/'
%  FS.TMILocation='./TMI.mat';
%  FS.GetBinsElsewhere='../Climate0/ClimateLibrary/';
% OutputStructure=MakeClimateSpaceLibraryFunctionRevP(FS);
%
%
%
% Get crop information section

Rev='P';

CropNames={'maize','wheat'};
Nspace=[5 10];
GDDBaseDir='GDDLibrary/';
TMILocation='./TMI.mat';
AILocation='./AI.mat';
%AnnualMeanPrec='./AnnualMeanPrec.mat';
SaveFileNameBaseDir='./ClimateLibrary';
DataYear=2000;
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
    for jcrop=1:length(CropNames);
        for   jwf=[2];
            jhf=1
            
            cropname=char(CropNames(jcrop));
            
            GDDTempstr=GetGDDBaseTemp(cropname);
            
            %Rev B settings:
            PercentToDrop=0;  % "5" to force a 5% of cultivated area bin at top and bottom
            
            
            
            
            
            disp(['Working on ' cropname ' for ' int2str(DataYear)]);
            
            
            %% read in crop netCDF file, extract area fraction.
            CropData=getcropdata(cropname,DataYear);
            
            
            AreaFraction=CropData.Data(:,:,1);
            AreaFraction(find(AreaFraction>1e10))=NaN;
            
            
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
                case 5
                    WetFlag='AI'
            end
            
            
            switch jhf
                case 1
                    HeatFlag='GDD'
                case 2
                    HeatFlag='GSL'
            end
            
            if DataYear==2000
                FileName=[SaveFileNameBaseDir '/ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
                    'x' int2str(N) '_RevP'];
                
                NoBaseFileName=['/ClimateMask_' cropname '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
                    'x' int2str(N) '_RevP'];
            else
                FileName=[SaveFileNameBaseDir '/ClimateMask_' cropname '_' int2str(DataYear) '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
                    'x' int2str(N) '_RevP'];
                
                NoBaseFileName=['/ClimateMask_' cropname '_' int2str(DataYear) '_' HeatFlag  GDDTempstr '_' WetFlag '_' int2str(N) ...
                    'x' int2str(N) '_RevP'];
            end
            
            
            
            if exist([FileName '.mat'])==2
                disp(['Already have ' FileName '.mat'])
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
                    case 'AI'
                        load(AILocation);
                        Prec=AI;
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
                    
                    % RevP - if Cultivated Area ==0, then do not take those
                    % bins into account when calculating Bin Edges.
                    
                    tempvar=Heat;
                    ii=(CultivatedArea==0);
                    tempvar(ii)=1e20;  % this will cause these guys to be ignored
                    
                    [PrecBinEdges,GDDBinEdges,xbins,ybins,ContourMask,InsideContourLogical,ContourStructure]= ...
                        CalculateBins_Globally_RevP(Prec,tempvar,...
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
                    %         RefineClimateSpaceRevP(Heat,Prec,CultivatedArea,CDS,xbins,ybins,ContourMask,[cropname ' ' WetFlag]);
                    
                    %     %% Make Climate Space
                    
                    %     CDS=CDSnew;
                else
                    %% Get bins from somewhere else
                    disp(['Getting Bins from ' GetBinsElsewhere]);
                    %load([GetBinsElsewhere filesep NoBaseFileName],'CDS','InsideContourLogical');
                    load([GetBinsElsewhere filesep NoBaseFileName],'CDS',...
                        'InsideContourLogical','ContourMask','xbins','ybins',...
                        'ContourStructure');
                end
                
                [BinMatrix,ClimateDefs]=...
                    ClimateDataStructureToClimateBins(CDS,Heat,Prec,CultivatedArea,HeatFlag,WetFlag,InsideContourLogical);
                
                
                %%
                %Now can make a plot
                
                MultiBoxPlotInClimateSpace(CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,InsideContourLogical);
                
                %%
                save(FileName,'BinMatrix','ClimateDefs','Prec','GDD',...
                    'PercentToDrop','WetFlag','HeatFlag','CultivatedArea',...
                    'CDS','InsideContourLogical','GDDTempstr','ContourMask','xbins','ybins',...
                    'ContourStructure');
                DAS.Description=['Climate Space Library, Revision ' Rev '. ' datestr(now)];
                WriteNetCDF(Long,Lat,single(BinMatrix),'ClimateMask',[FileName '.nc'],DAS);
                S=OpenNetCDF([FileName '.nc']);
                dos(['gzip  ' FileName '.nc']);
            end
            close all
        end
        
    end
    
end
