NSS.cmap='jgbrownyellowgreen';


bd='/Users/jsgerber/sandbox/jsg003_YieldGapWork/DeltaClimate/ClimateSpace0/YieldGaps/ContourFiltered';

load([bd '/YieldGap_Wheat_MaxYieldPct_95_ContourFilteredClimateSpace_5x5_prec.mat'])


NSS.FastPlot='on';

NiceSurfGeneral(OS.ClimateMask,NSS);

ii=(OS.ClimateMask==10);
NSS.cmap='revjgbrownyellowgreen';
NSS.cmap=[1 1 1];
NSS.FastPlot='on';
jj=ii+1;
jj(~ii)=NaN;
NiceSurfGeneral(jj,NSS);


kk=(ii & OS.Yield<9e9 & OS.Area<9e9);
y=OS.Yield(kk);
a=OS.Area(kk);

[yieldsort,iNewOrder]=sort(y);

ca=cumsum(a(iNewOrder));

figure
plot(ca/max(ca)*100,y(iNewOrder))

%%%%%




clear NSS
	  NSS.lowermap='white';
	  NSS.cmap='area2';
%	  NSS.plotarea='europe';
%NSS.coloraxis=([min(OS.Yield(ii)) max(OS.Yield(ii))]);
NSS.coloraxis=([0 1])
	  NiceSurfGeneral(ii,NSS);
colorbar off

	  	  COLORMAP='brightyield';

COLORMAP='jgbrownyellowgreen';
	  
	  
	  NSS.cmap='revsummer';
	  NSS.cmap='revjfgreen-brown';	
      
      
	  NSS.cmap=COLORMAP;
      c=finemap(COLORMAP);
	  NSS.LogicalInclude=kk;
NSS.Units='tons/ha';
	  NSOS=NiceSurfGeneral(OS.Yield,NSS);
%%%%%
x=ca;
y=yieldsort;

  figure
%c=finemap('revjgbrownyellowgreen')
%c=finemap('brightyield');

	  


%	  c=colormap;
	  cax=NSOS.coloraxis;
	  jj=round(linspace(1,length(x),length(c)));;
	  
%	  for j=2:length(c)-1   %ignore first/last points since c
                                %was set up in NiceSurfGeneral
                                %which puts on upper/lower colors
			
				for j=1:length(jj)-1
				j1=jj(j);
				j2=jj(j+1);
				ymin=y(j1);
				ymax=y(j2);
				
				ymean=(ymin+ymax)/2;
				
				cindex= round( length(c)* ...
					(  (ymean-cax(1))/(cax(2)-cax(1))) ...
					 );
				
                 cindex=max(cindex,1);
                 
				c3=c(cindex,:);
				
				kk=j1:j2;
				hl=line(x(kk)*100,y(kk));
				set(hl,'color',c3);
				end
				
	  
	  xlabel('% cumulative area')
	  ylabel('tons/ha')
	  title(['Wheat yield vs yield-sorted cultivated area. "Paris" climate bin'])
	  grid on
	  fattenplot

