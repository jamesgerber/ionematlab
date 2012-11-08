% have 
CultivatedArea      4320x2160            74649600  double              
GDD                 4320x2160            74649600  double              
TMI                 4320x2160            74649600  double              
Yield               4320x2160            74649600  double   
  
  
  
iiLogical=(CultivatedArea >0 & isfinite(CultivatedArea) ...
  & DataMaskLogical & isfinite(Yield) & isfinite(TMI) ...
  & Yield<1e10);
  ii=find(iiLogical);

  spare GDD TMI Yield CultivatedArea ii iiLogical
  DoubleAllVars
  g=GDD(ii);
  t=TMI(ii);
  y=Yield(ii);
  w=CultivatedArea(ii);
  s = t*.01;
  s = s(:);
  
FO = fitoptions('Method', 'LinearLeastSquares')
x = [g t s];
[FO, G, O] = FIT(x, y, 'poly111', 'weight', w)