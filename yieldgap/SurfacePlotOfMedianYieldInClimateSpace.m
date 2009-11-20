GDDBinCenters=(GDDBinEdges(1:end-1)+GDDBinEdges(2:end))/2;
PrecBinCenters=(PrecBinEdges(1:end-1)+PrecBinEdges(2:end))/2;

TotalArea=NaN*ones(N,N);

c=1;
clear x y z

for iG=1:N;
  for iP=1:N;
    ibin=(iG-1)*N+iP;

    x(c)=GDDBinCenters(iG);
    y(c)=PrecBinCenters(iP);
    
    ii=find(ClimateMask==ibin & CropMaskLogical);
    
               TotalArea(iG,iP)=sum(CultivatedArea(ii));
                z(c)=sum(CultivatedArea(ii));
		c=c+1;
            end
end

z=z/max(z);
TotalAreaNorm=TotalArea/sum(sum(TotalArea));

figure('position',[107   654   560   420])
%surface(GDDBinCenters,PrecBinCenters,TotalAreaNorm.');
TAN=TotalAreaNorm;
TAN(end+1,end+1)=0;
surface(GDDBinEdges,PrecBinEdges,TAN.')
xlabel([HeatFlag]);
ylabel(WetFlag)
title(['Distribution of cultivated area in climate space.' ...
       cropname  '. ' Nstr 'x' Nstr '.' WetFlag ',' HeatFlag '. Rev' Rev])
caxis([0 .05])
   %   colorbar
%   zeroxlim(GDDBinEdges(1),GDDBinEdges(end));
%   zeroylim(PrecBinEdges(1),PrecBinEdges(end));
untex
OutputFig('Force',['Distribution of cultivated area in climate space.' ...
       cropname  '. ' Nstr 'x' Nstr '.' WetFlag ',' HeatFlag '_SurfacePlot. Rev' Rev])
% 
% figure
% stem3(x,y,z)
% xlabel([HeatFlag]);
% ylabel(WetFlag)
% title(['Distribution of cultivated area in climate space.' ...
%        cropname  '. ' Nstr 'x' Nstr '.' WetFlag ',' HeatFlag ])
% untex
% OutputFig('Force',['Distribution of cultivated area in climate space.' ...
%        cropname  '. ' Nstr 'x' Nstr '.' WetFlag ',' HeatFlag '_StemPlot'])

