% have 
 CultivatedArea      4320x2160            74649600  double              
  GDD                 4320x2160            74649600  double              
  TMI                 4320x2160            74649600  double              
  Yield               4320x2160            74649600  double   
  
  
  
  iiLogical=(CultivatedArea >0 & isfinite(CultivatedArea) ...
      & DataMaskLogical & isfinite(Yield) & isfinite(TMI));
  ii=find(iiLogical);

  g=GDD(ii);
  t=TMI(ii);
  y=Yield(ii);
  w=CultivatedArea(ii);
  
  
