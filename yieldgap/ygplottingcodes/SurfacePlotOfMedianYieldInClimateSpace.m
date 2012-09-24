
 FS.ClimateSpaceRev='P';
    FS.CropNames='maize';
    FS.ClimateSpaceN=10;
    FS.WetFlag='prec';
    FS.PercentileForMaxYield=95;
    FS.DataYear=2000;
    OutputDirBase=[iddstring '/ClimateBinAnalysis/YieldGap/'];
    FileName=YieldGapFunctionFileNames_CropName(FS,OutputDirBase);

    load(FileName)
    
    N=FS.ClimateSpaceN;
    

TotalArea=NaN*ones(N,N);

c=1;
CultivatedArea=OS.Area;
clear x y z

for iG=1:N;
  for iP=1:N;
      ibin=(iG-1)*N+iP;
      
      GDDBinCenters(iG)= (OS.CDS(ibin).GDDmin+OS.CDS(ibin).GDDmax)/2;
      PrecBinCenters(iP)=(OS.CDS(ibin).Precmin+OS.CDS(ibin).Precmax)/2;
      
      
      x(c)=GDDBinCenters(iG);
      y(c)=PrecBinCenters(iP);
      
      ii=find(OS.ClimateMask==ibin & CropMaskLogical);
      
      TotalArea(iG,iP)=sum(CultivatedArea(ii));
      z(c)=sum(CultivatedArea(ii));
      c=c+1;
  end
end


 figure
 stem3(x,y,OS.VectorOfPotentialYields)
 xlabel('GDD');
 ylabel('Precipitation')
% title(['Distribution of cultivated area in climate space.' ...
%        cropname  '. ' Nstr 'x' Nstr '.' WetFlag ',' HeatFlag ])
% untex
% OutputFig('Force',['Distribution of cultivated area in climate space.' ...
%        cropname  '. ' Nstr 'x' Nstr '.' WetFlag ',' HeatFlag '_StemPlot'])

