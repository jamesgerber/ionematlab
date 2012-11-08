%%% code to make Balance plot

%  This will look for a file TotalCropProductionData.mat created by
%  CalculateTotalProduction.m


D=ReadGenericCSV([ adstring '/croptype_NPK.csv'],2);

%% Generate Croplist
try
    load MakeBalancePlotsOutput
catch
    croplist={};
    %   for j=1:length((D.N_Perc_Dry_Harv))
    %       if (length(D.N_Perc_Dry_Harv(j)) >1 & length(D.P_Perc_Dry_Harv(j)) >1)
    %         if isequal(D.Legume{j},'legume')
    % it's a legume.  only add to croplist if we have data
    %              if (length(D.Nfix_low{j}) >1)
    %
    %                  croplist{end+1}=D.CROPNAME{j};
    %              else
    %                  %a legume, but no Nfix data.  exclude
    %              end
    %         else
    %              croplist{end+1}=D.CROPNAME{j}
    
    %        end
    %      end
    croplist= D.CROPNAME;
    
    %end
    
    
    %% Plotting preliminaries / setup
    
    ExcessN_Tons_Gridcell=DataBlank;
    runningarea=DataBlank;
    ExcessP_Tons_Gridcell=DataBlank;
    
    totN=DataBlank;
    totP=DataBlank;
    %% run through croplist
    for j=1:length(croplist)
        crop=croplist{j};
        disp(['calling calc. balances for ' crop]);
        [C,N,P]=CalculateBalances(crop);
        
        tmp=N.ExcessNitrogenPerHA_x_Area;
        tmpP=P.ExcessPhosphorusPerHA_x_Area;
        
        if length(find(isfinite(tmp)))>1
            
            tmp_N_app_gridcell_tons=N.AppliedNitrogenPerHA.*N.Area.*fma/1000;
            tmp_P_app_gridcell_tons=P.AppliedPhosphorusPerHA.*N.Area.*fma/1000;
            tmp_N_ex_gridcell_tons=N.ExcessNitrogenPerHA_x_Area.*fma/1000;
            tmp_P_ex_gridcell_tons=P.ExcessPhosphorusPerHA_x_Area.*fma/1000;
            
            
            
            %% Find points with bad data quality
            % set them to zero
            ii1=abs(tmp_N_app_gridcell_tons)>1e10;
            ii2=isnan(tmp_N_app_gridcell_tons);
            iibad=ii1 | ii2;
            iibad1=iibad;
            
            tmp_N_app_gridcell_tons(iibad)=0;
            totN=totN+tmp_N_app_gridcell_tons;
            
            ii1=abs(tmp_P_app_gridcell_tons)>1e10;
            ii2=isnan(tmp_P_app_gridcell_tons);
            iibad=ii1 | ii2;
            tmp_P_app_gridcell_tons(iibad)=0;
            totP=totP+tmp_P_app_gridcell_tons;
            iibad2=iibad;
            
            % condition for N
            ii1=abs(tmp_N_ex_gridcell_tons)>1e10;
            ii2=isnan(tmp_N_ex_gridcell_tons);
            iibad=ii1 | ii2;
            tmp_N_ex_gridcell_tons(iibad)=0;
            ExcessN_Tons_Gridcell=ExcessN_Tons_Gridcell+tmp_N_ex_gridcell_tons;
            iibad3=iibad;
            
            % now condition for P
            ii1=abs(tmp_P_ex_gridcell_tons)>1e10;
            ii2=isnan(tmp_P_ex_gridcell_tons);
            iibad=ii1 | ii2;
            tmp_P_ex_gridcell_tons(iibad)=0;
            ExcessP_Tons_Gridcell=ExcessP_Tons_Gridcell+tmp_P_ex_gridcell_tons;
            iibad4=iibad;
            
            disp('equal iibad tests')
            aa1= isequal(iibad1,iibad3)
            %   aa2= isequal(iibad2,iibad3)
            aa3= isequal(iibad2,iibad4)
            
            if (aa1*aa3==0)
                error('inconsistent iibad')
            end
            % now area
            tmparea=N.Area;
            tmparea(iibad)=0;
            runningarea=runningarea+tmparea;
            
        else
            disp(['bad data for ' crop ]);
        end
    end
    
    save MakeBalancePlotsOutput
end

load([iddstring '/misc/TotalCropProductionData.mat'],'OS');
%
%% Construct poop transfer efficiency map (ptem)

%like liu
ptem=landmasklogical;
ptem=ptem*0.90;   %entire world
ii=logical(countrycodetooutline('USA'));
ptem(ii)=0.87;
ii=ContinentOutline({'Western Europe','Northern Europe','Southern Europe'});
ptem(ii)=0.66;
ii=CountryCodeToOutline('CAN');
ptem(ii)=0.66;


%% now manure
ManureBaseDir=[ iddstring '/misc/manure'];
SN=OpenGeneralNetCDF([ManureBaseDir '/Nmanure.nc']);
SP=OpenGeneralNetCDF([ManureBaseDir '/Pmanure.nc']);

%ExcessNitrogenPerHa_Avg=en./runningarea;
%ExcessPhosphorusPerHa_Avg=ep./runningarea;

CropArea=OpenNetCDF([iddstring '/Crops2000/Cropland2000_5min.nc']);
PastArea=OpenNetCDF([iddstring '/Crops2000/Pasture2000_5min.nc']);

ca=CropArea.Data;
pa=PastArea.Data;

clear CropArea
clear PastArea

Nmanure=disaggregate_rate(SN(6).Data,6).*(ca./(pa+ca));  %Estmiate of manure produced on feedlot.
Pmanure=disaggregate_rate(SP(6).Data,6).*(ca./(pa+ca));
% potter data is kg/ha over entire gridcell.

clear ca
clear pa
clear SN
clear SP

ExcessNitrogenPerGridCell_chem=ExcessN_Tons_Gridcell*1000;  %kg per gridcell
%AppliedNitrogenPerGridCell_manure=(Nmanure.*fma);
AppliedNitrogenPerGridCell_manure=(Nmanure.*fma).*ptem.*(1-0.36);  %kg. per gridcell.
%0.36 is the loss for nitrogen due to volatilization (used by liu,
%bouwman(?))

ExcessNitrogenPerGridCell=ExcessNitrogenPerGridCell_chem + AppliedNitrogenPerGridCell_manure;  %kg per grid cell
ExcessNitrogenPerHA_avg=ExcessNitrogenPerGridCell./(runningarea.*fma);  %kg per cultivated area


ExcessPhosphorusPerGridCell_chem=(ExcessP_Tons_Gridcell.*1000); %kg per gridcell
AppliedPhosphorusPerGridCell_manure=(Pmanure.*fma).*ptem;
ExcessPhosphorusPerGridCell=ExcessPhosphorusPerGridCell_chem + AppliedPhosphorusPerGridCell_manure;  %kg per grid cell
ExcessPhosphorusPerHA_avg=ExcessPhosphorusPerGridCell./(runningarea.*fma);

Total_Applied_Nitrogen_Per_GridCell=AppliedNitrogenPerGridCell_manure + totN.*1000; %  totN was in tons, move to kg
Total_Applied_Nitrogen_Per_CultivatedArea=Total_Applied_Nitrogen_Per_GridCell./(runningarea.*fma);

Total_Applied_Phosphorus_Per_GridCell=AppliedPhosphorusPerGridCell_manure + totP.*1000;
Total_Applied_Phosphorus_Per_CultivatedArea=Total_Applied_Phosphorus_Per_GridCell./(runningarea.*fma);;


%%
clear NSSBase
personalpreferences('printingres' ,     '-r1200' )

NSSBase.FastPlot='off';
NSSBase.PlotFlag='on';
NSSBase.MakePlotDataFile='on';
%NSSBase.lowermap='joanneblue';
%NSSBase.uppermap='gray';


% Fig 8a
NSS=NSSBase;
NSS.LogicalInclude=AreaFilter(runningarea,runningarea);
NSS.caxis=.95;
NSS.caxis=[0 90];
NSS.cmap='dark_greens_deep';
NSS.TitleString =  ['   Applied nitrogen on landscape.   '];
NSS.FileName    =  ['   Applied nitrogen per grid cell   '];
NSS.Units='kg per ha';
NSS.Colorbarfinalplus='off';
NSS.PanoplyTriangles=[0 1];
NiceSurfGeneral(totN./fma*1000,NSS);

% Fig 8b
NSS=NSSBase;
NSS.LogicalInclude=AreaFilter(runningarea,runningarea);
NSS.caxis=.95;
NSS.caxis=[0 14];
NSS.cmap='dark_greens_deep';
NSS.TitleString =  ['   Applied phosphorus on landscape.   '];
NSS.FileName    =  ['   Applied phosphorus per grid cell   '];
NSS.Units='kg per ha';
NSS.PanoplyTriangles=[0 1];
NiceSurfGeneral(totP./fma*1000,NSS);

% NSS=NSSBase;
% cmap=finemap('beige_white_blue_deep','','');
% NSS.Units='kg per ha';
% NSS.LogicalInclude=AreaFilter(runningarea,runningarea);
%
% newmap=TruncateColorMap(cmap,-10,250)
% NSS.coloraxis=[-10 300];
% NSS.cmap=newmap;
% NSS.Colorbarfinalplus='on';
% %NSS.Colorbarminus='on';
% NSS.TitleString =  ['   Excess nitrogen on cultivated land.   '];
% NSS.FileName    =  ['   Excess nitrogen on cultivated land    '];
% NiceSurfGeneral(ExcessNitrogenPerHA_avg,NSS);


NSS=NSSBase;
NSS.LogicalInclude=AreaFilter(runningarea,runningarea);
cmin=-10;
cmax=100;
NSS.cmap=TruncateColorMap(finemap('dark_purple_white_green','',''),cmin,cmax);
NSS.caxis=[cmin cmax];
NSS.TitleString =  ['   Excess nitrogen on landscape.   '];
NSS.FileName    =  ['   Excess nitrogen per grid cell   '];
NSS.Units='kg per ha'
NSS.PanoplyTriangles=[1 1];
NiceSurfGeneral(ExcessNitrogenPerGridCell./fma,NSS);
ExcessNitrogenOnLandscape=ExcessNitrogenPerGridCell./fma;

% Now make some data files
save ExcessNutrientDatasets ExcessNitrogenOnLandscape croplist


% now similar plot for phosphorus
% NSS=NSSBase;
% cmin=-10;
% cmax=100;
% NSS.cmap=TruncateColorMap(finemap('beige_white_blue_deep','',''),cmin,cmax);
% NSS.caxis=[cmin cmax];
% NSS.LogicalInclude=AreaFilter(runningarea,runningarea);
% NSS.Colorbarfinalplus='on';
% %NSS.Colorbarminus='on';
%
% NSS.TitleString =  ['   Excess phosphorus on cultivated land.  '];
% NSS.FileName    =  ['   Excess phosphorus on cultivated land  '];
% NSS.Units='kg per ha';
%
% NiceSurfGeneral(ExcessPhosphorusPerHA_avg,NSS);


NSS=NSSBase;
NSS.LogicalInclude=AreaFilter(runningarea,runningarea);
cmin=-5;
cmax=60;
NSS.cmap=TruncateColorMap(finemap('dark_purple_white_green','',''),cmin,cmax);
NSS.caxis=[cmin cmax];
NSS.TitleString =  ['   Excess phosphorus on landscape   '];
NSS.FileName    =  ['   Excess phosphorus per grid cell  '];
NSS.Units='kg per ha';
NSS.PanoplyTriangles=[1 1];
%NSS.Colorbarminus='on';
NiceSurfGeneral(ExcessPhosphorusPerGridCell./fma,NSS);


% now relative to total yields

ty=OS.SumProduction./(OS.SumArea.*fma); %total yield

LogicalInclude=AreaFilter(runningarea,runningarea) ;

% now excess nitrogen / total yield

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Excess Nitrogen per unit yield %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ExcessNitrogenPerYield=ExcessNitrogenPerHA_avg./ty;
% NSS=NSSBase;
% NSS.Units='kg N / ton';
% cmin=-10;
% cmax=60;
% NSS.cmap=TruncateColorMap(finemap('purple_white_green_deep','',''),cmin,cmax);
% NSS.caxis=[cmin cmax];
% NSS.FileName='excess nitrogen per ton yield';
% NSS.Title=' Excess nitrogen per ton yield ';
% NSS.LogicalInclude=LogicalInclude;
% NSS.Colorbarfinalplus='on';
% %NSS.Colorbarminus='on';
% NiceSurfGeneral(ExcessNitrogenPerYield,NSS);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Applied Nitrogen / total yield  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AppliedNitrogenPerYield=Total_Applied_Nitrogen_Per_CultivatedArea./ty;
NSS=NSSBase;
NSS.Units='kg N / ton';
NSS.cmap='dark_oranges_deep';
NSS.caxis=[.95];
NSS.caxis=[0 40];
NSS.FileName='applied nitrogen per ton yield';
NSS.Title=' Applied nitrogen per ton yield ';
NSS.LogicalInclude=LogicalInclude;
NSS.PanoplyTriangles=[0 1];
%NSS.Colorbarminus='on';
NiceSurfGeneral(AppliedNitrogenPerYield,NSS)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Applied Phosphorus / total yield %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AppliedPhosphorusPerYield=Total_Applied_Phosphorus_Per_CultivatedArea./ty;
NSS=NSSBase;
NSS.Units='kg P / ton';
NSS.cmap='dark_oranges_deep';
NSS.caxis=[.95];
NSS.FileName='applied phosphorus per ton yield';
NSS.Title=' Applied phosphorus per ton yield ';
NSS.LogicalInclude=LogicalInclude;
NSS.PanoplyTriangles=[0 1];
%NSS.Colorbarminus='on';
NiceSurfGeneral(AppliedPhosphorusPerYield,NSS)

%same thing ... categorical
% clear NSS
% NSS=NSSBase;
%     NSS.categorical='on';
%     NSS.categoryranges={[-15 0],[0 15],[15 30],[30 45],[45 60]}
%     NSS.cmap={'lime','green','b','magenta','maroon'};
%     tmp=finemap('yield','','');
%     NSS.cmap=tmp(10:end-10,1:3);
% NSS.FileName='excess nitrogen per ton yield_categorical2';
% NSS.Title=' Excess nitrogen per ton yield ';
% NSS.LogicalInclude=LogicalInclude;
% NSS.uppermap=[.99 .99 .99];
% NSS.lowermap='joannegray';
% NiceSurfGeneral(ExcessNitrogenPerYield,NSS);
%    %or%



% % now excess phosph / total yield
%
% LogicalInclude=AreaFilter(runningarea,runningarea) ;
%
% ExcessPhosphorusPerYield=ExcessPhosphorusPerHA_avg./ty;
% NSS=NSSBase;
% NSS.Units='kg P / ton';
%
% cmin=-5;
% cmax=25;
% NSS.cmap=TruncateColorMap(finemap('purple_white_green_deep','',''),cmin,cmax);
% NSS.caxis=[cmin cmax];
% NSS.FileName='excess phosphorus per ton yield';
% NSS.Title=' Excess phosphorus per ton yield ';
% NSS.LogicalInclude=LogicalInclude;
% NSS.Colorbarfinalplus='on';
% %NSS.Colorbarminus='on';
% NiceSurfGeneral(ExcessPhosphorusPerYield,NSS);


%% Now try to figure out the relevant numbers:

croparea=runningarea;
croparea=OS.SumArea;
% Nitrogen
ii=(croparea>0 & isfinite(croparea) & croparea < 9e20 & ...
    isfinite(ExcessNitrogenPerHA_avg));%  & AreaFilter(runningarea,runningarea));

a=croparea(ii).*fma(ii);
nrate=ExcessNitrogenPerHA_avg(ii);

[dum,ii]=sort(nrate,'descend');

asort=a(ii);
nratesort=nrate(ii);

acum=cumsum(asort);
acum=acum/max(acum);

[dum,jj]=min( (acum-0.10).^2)
acutoff=asort(jj)

totalarea=(sum(asort))

%total pollution in the first 10% of area

TopTenExcessNitrogen=sum( asort(1:jj).*nratesort(1:jj));
TotalExcessNitrogen=sum( asort(1:end).*nratesort(1:end));

NitrogenRatio=TopTenExcessNitrogen/TotalExcessNitrogen

% Phosphorus
ii=(croparea>0 & isfinite(croparea) & croparea < 9e20 & ...
    isfinite(ExcessPhosphorusPerHA_avg) );% & AreaFilter(runningarea,runningarea));

a=runningarea(ii).*fma(ii);
prate=ExcessPhosphorusPerHA_avg(ii);

[dum,ii]=sort(prate,'descend');

asort=a(ii);
pratesort=prate(ii);

acum=cumsum(asort);
acum=acum/max(acum);

[dum,jj]=min( (acum-0.1).^2);

%total pollution in the first 10% of area

TopTenExcessPhosphorus=sum( asort(1:jj).*pratesort(1:jj));
TotalExcessPhosphorus=sum( asort(1:end).*pratesort(1:end));
PhosphorusRatio=TopTenExcessPhosphorus/TotalExcessPhosphorus

