function [XXXBinEdges,YYYBinEdgesCell,xbins,ybins,ContourMask]= ...
    CalculateBins_Globally_RevH(YYY,XXX,Area,Nbin,Nsurface,PercentToDrop,cropname);
%   CalculateBins_EqualAreaSpace
%
%     SYNTAX:
%    [YYYBinEdges,XXXBinEdges]=CalculateBins_CenteredSpace(YYY,XXX,Area); 
%
%

% first exclude points: draw a contour which will exclude 5% of area.  Note
% that we need to do this by making a surface in GDD/Moisture space and
% doing calculations in there.


if nargin<7
    cropname='unspecified crop'
    debugplots=0;
else
    debugplots=1;
end


IsValidData=(CropMaskLogical & XXX < 1e15 & isfinite(XXX) & Area>eps & isfinite(Area));

W=Area(IsValidData); %Weight is the area, but only for these points.
[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(XXX(IsValidData),YYY(IsValidData),Nsurface,Nsurface+10,W);

jpmax=monotonicdistribution(jp);

p=0.95;

[ContourMask,CutoffValue]=FindContour(jp,jpmax,p);

%% now need to find indices of points which live inside the selected area.

if debugplots==1
    figure
    surface(double(xbins),double(ybins),double(jp).');
    shading flat
    xlabel('GDD');
    ylabel('TMI');
    %zeroylim(0,6);
    grid on
    ylims=get(gca,'YLim');
    title([' All cultivated areas. ' cropname ' (made in calcbins revh) ']);
    fattenplot
    finemap('area2')
    OutputFig('Force')
    
    figure;surface(xbins,ybins,double(jp.*ContourMask).')
    xlabel('GDD');
    ylabel('TMI');
    zeroylim(ylims(1),ylims(2));
    grid on
    ylims=get(gca,'YLim');
    title([' Contour-filtered areas. ' cropname ' (made in calcbins revh) ']);
    fattenplot
    shading flat
    finemap('area2')
    OutputFig('Force')
end


%% need to find indices of points inside the contour


y=YYY;%(IsValidData);
x=XXX;%(IsValidData);
A=Area;%(IsValidData);

% look at each individual bin.  If this bin is inside the contour, then
% add all of the point indices to the good list.

%not that it would be possible to look at first/last bins in X, first/last
%bins in Y if ContourMask were a convex polygon.  I don't want that
%constraint.

GoodList=0*x;

for j=1:length(xbins)
    ii=find(x >= XBinEdges(j) & x < XBinEdges(j+1));
    for m=1:length(ybins)
        if ContourMask(j,m)==1
        
            jj=find(y(ii) >= YBinEdges(m) & y(ii) < YBinEdges(m+1));
            
            GoodList(ii(jj))=1;
        end
    end
end

GoodList=logical(GoodList);

GoodList=GoodList & IsValidData;

xcr=XXX(GoodList);
ycr=YYY(GoodList);
Acr=A(GoodList);
%% now make a plot with the contour-rejected points
if debugplots==1
    [jp,xbins,ybins]=GenerateJointDist(xcr,ycr,XBinEdges,YBinEdges,W);

    figure
    surface(double(xbins),double(ybins),double(jp).');
    xlabel('GDD');
    ylabel('TMI');
    zeroylim(ylims(1),ylims(2));
    grid on
    ylims=get(gca,'YLim');
    title([' Scatter plot from all contour-filtered data ' cropname ...
        ' (made in calcbins revh) ']);
    fattenplot
    shading flat
    finemap('area2')
    OutputFig('Force')
end

p=PercentToDrop/100;

[XXXBinEdges]=GetBins(xcr,Acr,Nbin,0,'XXX');

% now have XXXBinEdges.

%for each XXXBin, let's get a set of YYYBins

for j=1:length(XXXBinEdges)-1;
% note that it is the same procedure as above, except that now when
% we get indiceswecareabout it will be limit to those within each
% precipitation bin.
  IndicesIsValidDataAbout=find(xcr >=XXXBinEdges(j) & xcr < XXXBinEdges(j+1));
  x=xcr(IndicesIsValidDataAbout);
  y=ycr(IndicesIsValidDataAbout);
  A=Acr(IndicesIsValidDataAbout);
  YYYBinEdgesCell{j}=GetBins(y,A,Nbin,p,'YYY');  
end

% % % disp('text');
% % % %% old fashioned bin calculation (code copied from MakeClimateSpace)
% % % 
% % % % prep for copied code
% % % 
% % % WaterBins=YYYBinEdgesCell;
% % % TempBins=XXXBinEdges;
% % % T=xcr;
% % % W=ycr;
% % % TempDataName='GDD';
% % % WaterDataName='Water';
% % % 
% % % %copied code
% % % if iscell(WaterBins)
% % %     NW=length(WaterBins);
% % % else
% % %     NW=length(WaterBins)-1;
% % % end
% % % 
% % % if iscell(TempBins)
% % %     NT=length(TempBins);
% % % else
% % %     NT=length(TempBins)-1;
% % % end
% % % 
% % % for mW=1:NW
% % %     for mT=1:NT
% % %         ClimateBinNumber=(mW-1)*NT+mT;
% % %                
% % %         if iscell(WaterBins)
% % %             WaterBinsThisTempBin=WaterBins{mT};
% % %             Wmin=WaterBinsThisTempBin(mW);
% % %             Wmax=WaterBinsThisTempBin(mW+1);
% % %         else
% % %             % Water variable limits
% % %             Wmin=WaterBins(mW);
% % %             Wmax=WaterBins(mW+1);
% % %         end
% % %          
% % %         %Temperature variable limits        
% % %         if iscell(TempBins)
% % %             TempBinsThisWaterBin=TempBins{mW};
% % %             Tmin=TempBinsThisWaterBin(mT);
% % %             Tmax=TempBinsThisWaterBin(mT+1);
% % %         else
% % %             Tmin=TempBins(mT);
% % %             Tmax=TempBins(mT+1);
% % %         end
% % %                
% % %         % who fits?
% % %         jj=find( T >= Tmin & T <Tmax & W >= Wmin & W <Wmax);
% % %         
% % %         ClimateBinVector(jj)=ClimateBinNumber;
% % %         ClimateDefs{ClimateBinNumber}=...
% % %             ['Bin No ' int2str(ClimateBinNumber) '.   ' ...
% % %             num2str(Tmin) '< ' TempDataName ' <= ' num2str(Tmax) ',   ' ...
% % %             num2str(Wmin) '< ' WaterDataName ' <= ' num2str(Wmax) ];
% % %         CDS(ClimateBinNumber).GDDmin=Wmin;
% % %         CDS(ClimateBinNumber).GDDmax=Wmax;
% % %         CDS(ClimateBinNumber).Precmin=Tmin;
% % %         CDS(ClimateBinNumber).Precmax=Tmax;
% % %     end
% % % end
% % % 
% % % 
% % % 
% % % 
% % % 
function [xbins]=GetBins(x,y,N,p,str);
[xsort,ii]=sort(x);

ysort=y(ii);

ysum=cumsum(ysort);
AreaNorm=ysum/max(ysum);

i5=min(find(AreaNorm>=p));
i95=max(find(AreaNorm<=(1-p)));
% remember i5, i95 are conceptually bottom and top 5th percentile.  May in
% fact by 0th or 10th ...

x5=xsort(i5);
x95=xsort(i95);

if p==0
    %if p==0, go out to ends.
    N=N+2;
end
% now want to get bins between p and 1-p
TargetAreas=[linspace(p,1-p,(N-1))];

for j=1:(N-1);
    IndexVector(j)=min(find(AreaNorm>=TargetAreas(j)));
    xbins(j)=xsort(IndexVector(j));
end

if p>0
    % tack on 1, length(y) to xbins
    xbins=[min(x) xbins max(x)];
end

MakePlot=0;
if MakePlot
    figure
    plot(xsort,AreaNorm);
    hold on
    ylabel(['Normalized Cumulative Area with ' str])
    xlabel(str);
    for j=1:length(xbins);
        plot([1 1]*xbins(j),[0 1],'r');
    end
end
    
% % %     
% % %     
    
