function MultiBoxPlotInClimateSpace...
    (CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,IsValidData)
% MultiBoxPlotInClimateSpace - generate a scatter plot, put boxes over it.
%
%   Syntax
%     PatchPlotOfAreaInClimateSpace...
%    (CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,IsValidData)
%
Nsurface=300;

if nargin<7
    WetFlag='Moisture Index';
end


if nargin<8
    IsValidData=(CropMaskLogical & Heat < 1e15 & isfinite(Heat) & CultivatedArea>eps & isfinite(CultivatedArea));
end



% check to make sure that heat/prec are positvite
 IsValidData=IsValidData & (Heat > -8e8 & Prec > -8e8); 
 

W=CultivatedArea(IsValidData); %Weight is the area, but only for these points.
[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(Heat(IsValidData),Prec(IsValidData),Nsurface,Nsurface+10,W);




%% now need to find indices of points which live inside the selected area.

TotalArea=sum(sum(jp));

jp=jp/max(max(jp));

figure
surface(double(xbins),double(ybins),double(jp).');
shading flat
xlabel('GDD');
ylabel(WetFlag);
%zeroylim(0,6);
grid on
ylims=get(gca,'YLim');
title([' All cultivated areas. ' cropname ' ' WetFlag ' Rev' Rev]);
fattenplot
finemap('area2')

hold on











%
%[BinMatrix]=...
%    ClimateDataStructureToClimateBins(CDS,Heat,Prec,CultivatedArea,'heat','prec');




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
    
    % ii=find(BinMatrix==ibin & CropMaskLogical & ...
    %     Heat > x(1) & Heat < x(3) & ...
    %     Prec > y(1) & Prec < y(3));
    % TotalArea=sum(CultivatedArea(ii))
    
    line(x,y,0*x+1);
    % TotalAreaVect(ibin)=TotalArea;
end

ylabel(WetFlag)
xlabel('GDD')
title([' Cultivated area (less bottom 5%)  with climate bins.  ' cropname  '. ' WetFlag '. Rev' Rev '  ']);
h=colorbar

hy=get(h,'YLabel')
set(hy,'String',['normalized area per pixel (total=' num2str(TotalArea/1e6,4) 'Mha)'])
set(hy,'String',['Cultivated area (normalized)'])
set(hy,'FontWeight','Bold')

grid off

N=sqrt(length(CDS));
nbyn=[num2str(N) 'x' num2str(N)]
OutputFig('Force',['Figures/' cropname 'BoxScatterPlot_' WetFlag '_' nbyn '_' ' Rev' Rev])
%OutputFig('Force')