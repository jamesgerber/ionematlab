function PatchPlotOfAreaInClimateSpace...
    (CDS,CultivatedArea,Heat,Prec,cropname,Rev)
% PatchPlotOfAreaInClimateSpace
%
%   Syntax
%     PatchPlotOfAreaInClimateSpace...
%    (CDS,CultivatedArea,Heat,Prec,cropname,Rev)
%


[BinMatrix]=...
    ClimateDataStructureToClimateBins(CDS,Heat,Prec,CultivatedArea,'heat','prec');


figure

for ibin=1:length(CDS)

  S=CDS(ibin);
  x(1)=S.GDDmin;
  x(2)=S.GDDmin;
  x(3)=S.GDDmax;
  x(4)=S.GDDmax;  
  x(5)=S.GDDmin;    
  
  y(1)=S.Precmin;
  y(2)=S.Precmax;  
  y(3)=S.Precmax;    
  y(4)=S.Precmin;  
  y(5)=S.Precmin;       
  x=double(x);y=double(y);

  ii=find(BinMatrix==ibin & CropMaskLogical & ...
      Heat > x(1) & Heat < x(3) & ...
      Prec > y(1) & Prec < y(3));
  TotalArea=sum(CultivatedArea(ii))
  
  patch(x,y,TotalArea);
  TotalAreaVect(ibin)=TotalArea;
end

ylabel('Moisture Index')
xlabel('GDD')
title([cropname  ' ' 'Moisture Index' '. Rev' Rev]);
colorbar
%OutputFig('Force')