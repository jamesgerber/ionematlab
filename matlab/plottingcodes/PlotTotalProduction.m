OS=CalculateTotalProduction;


expandstructure(OS)
    
%% Yield
NSS.TitleString=lower(['  Total production.  All crops, All land ' ]);
NSS.cmap='nathangreenscale2';
NSS.FileName=['AllCrops_production'];
NSS.Units='tons / gridcell'
NSS.coloraxis=[.98];

NSO=NiceSurfGeneral(OS.SumProduction,NSS)


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


