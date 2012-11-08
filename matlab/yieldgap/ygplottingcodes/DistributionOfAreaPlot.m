% DistributionOfAreaPlots

% Get areas of interest.
IndicesWeCareAbout=find(CropMaskLogical & Prec < 1e15);
x=GDD(IndicesWeCareAbout);
y=Prec(IndicesWeCareAbout);
A=CultivatedArea(IndicesWeCareAbout);

[xsort,ii]=sort(x);
Asort=A(ii);
Asum=cumsum(Asort);
AreaNorm=Asum/max(Asum);


xbins=GDDBinEdges;

figure
plot(xsort,AreaNorm);
hold on
ylabel(['Normalized Cumulative Area with GDD' ])
xlabel('GDD');
for j=1:length(xbins);
  plot([1 1]*xbins(j),[0 1],'r');
end
grid on
title(['Normalized Cumulative Area with GDD Bins. ' cropname '. Rev' Rev])
fattenplot
zeroxlim(GDDBinEdges(1),GDDBinEdges(end));
OutputFig('Force')

[ysort,ii]=sort(y);
Asort=A(ii);
Asum=cumsum(Asort);
AreaNorm=Asum/max(Asum);
xbins=PrecBinEdges
figure
plot(ysort,AreaNorm);
hold on
ylabel(['Normalized Cumulative Area with ' WetFlag ])
xlabel(WetFlag);
for j=1:length(xbins);
  plot([1 1]*xbins(j),[0 1],'r');
end
grid on
title(['Normalized Cumulative Area with ' WetFlag ' Bins. ' cropname '. Rev' Rev])
fattenplot
OutputFig('Force')


figure
plot(AreaNorm,ysort);
hold on
xlabel(['Normalized Cumulative Area with ' WetFlag ])
ylabel(WetFlag);
for j=1:length(xbins);
  plot([0 1],[1 1]*xbins(j),'r');
end


zeroylim(PrecBinEdges(1),PrecBinEdges(end));grid on
title(['Normalized Cumulative Area with ' WetFlag ' Bins. ' cropname '. Rev' Rev])
fattenplot
OutputFig('Force')

