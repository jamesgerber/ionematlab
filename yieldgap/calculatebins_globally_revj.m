function [XXXBinEdges,YYYBinEdgesCell,xbins,ybins,ContourMask]= ...
    CalculateBins_Globally_RevJ(YYY,XXX,Area,Nbin,Nsurface,...
    PercentToDrop,cropname,WetFlag,HeatFlag);
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
[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(XXX(IsValidData),YYY(IsValidData),Nsurface,Nsurface,W);

%% construct a different type of distribution / get a different contour
%want a rectangular one.  Discard 5% of points outside of contour.
jpmax=monotonicdistribution(jp);
tmp=sum(jpmax)

jptmp=repmat(tmp',1,Nsurface)';


p=0.975;

[ContourMask1,CutoffValue]=FindContour(jp,jptmp,p);


tmp=sum(jpmax,2)

jptmp=repmat(tmp,1,Nsurface);

%jpmax=monotonicdistribution(jptmp);

p=0.975;

[ContourMask2,CutoffValue]=FindContour(jp,jptmp,p);

ContourMask=ContourMask1 & ContourMask2;

%% now need to find indices of points which live inside the selected area.

if debugplots==1
    figure
    surface(double(xbins),double(ybins),double(jp).');
    shading flat
    xlabel(HeatFlag);
    ylabel(WetFlag);
    %zeroylim(0,6);
    grid on
    ylims=get(gca,'YLim');
    title([' All cultivated areas. ' cropname ' ' WetFlag ' RevJ']);
    fattenplot
    finemap('area2')
    OutputFig('Force')
    
    figure;surface(xbins,ybins,double(jp.*ContourMask).')
    xlabel(HeatFlag);
    ylabel(WetFlag);
    zeroylim(ylims(1),ylims(2));
    grid on
    ylims=get(gca,'YLim');
    title([' Contour-filtered areas. ' cropname ' ' WetFlag ' RevJ']);
    fattenplot
    shading flat
    finemap('area2')
    OutputFig('Force')

    figure;surface(xbins,ybins,double(ContourMask).')
    xlabel(HeatFlag);
    ylabel(WetFlag);
    zeroylim(ylims(1),ylims(2));
    grid on
    title([' 95% Contour ' cropname ' ' WetFlag ' RevJ']);
    fattenplot
    shading flat
    finemap('jet')
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
    xlabel(HeatFlag);
    ylabel(WetFlag);
    zeroylim(ylims(1),ylims(2));
    grid on
    ylims=get(gca,'YLim');
    title([' Scatter plot from contour-filtered data ' cropname ...
         ' ' WetFlag ' RevJ']);
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



%%%%%%%%%%%%%%
%  GetBins   %
%%%%%%%%%%%%%%
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

MakePlot=1;
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
    
