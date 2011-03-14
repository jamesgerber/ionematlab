%function PlotTotalProduction;

cl=croplist;


SumProduction=DataBlank;
SumArea=DataBlank;

fma=GetFiveMinGridCellAreas;

for j=1:length(cl) 
%
    S=OpenNetCDF([iddstring '/Crops2000/crops/' cl{j} '_5min.nc'])
    Area=S.Data(:,:,1);
    Yield=S.Data(:,:,2);


    DataMask=(Area > 0 & isfinite(Area.*Yield) & Area < 9e19 & Yield < 9e19);
   
    SumProduction(DataMask)=SumProduction(DataMask)+Area(DataMask).*Yield(DataMask).*fma(DataMask);
    SumArea(DataMask)=SumArea(DataMask)+Area(DataMask);
end
    
    
%% Yield
NSS.TitleString=lower(['  Total production.  All crops, All land ' ]);
NSS.cmap='nathangreenscale2';
NSS.FileName=['AllCrops_production'];
NSS.Units='tons / gridcell'
NSS.coloraxis=[.98];

NSO=NiceSurfGeneral(SumProduction,NSS)


SumYield=SumProduction./(SumArea.*fma);


NSS.TitleString=lower(['  Total yield.  All crops ' ]);
NSS.cmap='nathangreenscale2';
NSS.FileName=['AllCrops_yield'];
NSS.Units='tons / ha'
NSS.coloraxis=[.98];
NSO=NiceSurfGeneral(SumYield,NSS)


%%
NSS.TitleString=lower(['  Total yield.  All crops.  All land. ' ]);
NSS.cmap='nathangreenscale2';
NSS.FileName=['AllCrops_avgyield_allland'];
NSS.Units='tons / ha'
NSS.coloraxis=[.98];
NSO=NiceSurfGeneral(SumProduction./fma,NSS)

%%
save working
%keyboard


