function [XXXBinEdges,YYYBinEdgesCell,xbins,ybins,ContourMask,InsideContourLogical]= ...
    CalculateBins_Globally_RevP(YYY,XXX,Area,Nbin,Nsurface,...
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

iiAreaInclude=AreaFilter(Area,Area);

IsValidData=(CropMaskLogical & XXX < 1e15 & isfinite(XXX) & Area>eps & isfinite(Area) & ...
    XXX > -8e8 & YYY > -8e8  & iiAreaInclude);

if isequal(cropname,'unitcrop')
    disp(['unit crop'])
IsValidData=( XXX < 1e15 & isfinite(XXX) & Area>eps & isfinite(Area) & ...
    XXX > -8e8 & YYY > -8e8 );
end



W=Area(IsValidData); %Weight is the area, but only for these points.
[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(XXX(IsValidData),YYY(IsValidData),Nsurface,Nsurface,W);

%jpmax=monotonicdistribution(jp);

% % % p=0.95;
% % % 
% % % %[ContourMask,CutoffValue]=FindContour(jp,jpmax,p);
% % % 
% % % Dist=jp;
% % % Lsmooth=1;  %bec. need to smooth via kx / ky
% % % MaxNumCont=1;  % can have many contours ... why not?
% % % 
% % % kx=1/(Nsurface/20);  %x/y will go from -Nbin/2 to Nbin/2.   So make Lsmooth (Nbin/20)
% % % ky=1/(Nsurface/20);
% % % 
% % % 
% % % % make modification to Lsmooth and kx/ky.  Want them both to increase in
% % % % size.  We get the same effects, but FCSC uses Lsmooth.
% % % 
% % % 
% % % Lsmooth=Lsmooth*10;
% % % kx=kx*10;
% % % ky=ky*10;
% % % 
% % % 
% % % 
% % % 


%%%[ContourMask,CutoffValue,NumContours,RecLevel,CS]=...
%%%    FindCompactSmoothContourRevP(Dist,p,Lsmooth,kx,ky,MaxNumCont);

% For this Rev, do not call contour thing ... all points are acceptable

ContourMask=ones(size(jp));


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

InsideContourLogical=GoodList;


xcr=XXX(GoodList);
ycr=YYY(GoodList);
Acr=A(GoodList);


p=PercentToDrop/100;

[XXXBinEdges]=GetBins(xcr,Acr,Nbin,0,'XXX');


YYYBinEdges=GetBins(ycr,Acr,Nbin,0,'YYY');
% now have XXXBinEdges.

%for each XXXBin, let's get a set of YYYBins

for j=1:length(XXXBinEdges)-1;
% note that it is the same procedure as above, except that now when
% we get indiceswecareabout it will be limit to those within each
% precipitation bin.
% %   IndicesIsValidDataAbout=find(xcr >=XXXBinEdges(j) & xcr < XXXBinEdges(j+1));
   IndicesIsValidDataAbout=find(xcr >=XXXBinEdges(1) & xcr < XXXBinEdges(end));
   x=xcr(IndicesIsValidDataAbout);
   y=ycr(IndicesIsValidDataAbout);
   A=Acr(IndicesIsValidDataAbout);
   YYYBinEdgesCell{j}=GetBins(y,A,Nbin,0,'YYY');
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
   % function testcode
        
