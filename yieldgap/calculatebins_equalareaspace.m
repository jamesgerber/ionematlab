function [GDDBinEdges,PrecBinEdges]= ...
    CalculateBins_EqualAreaSpace(GDD,Prec,Area,N,PercentToDrop);
%   CalculateBins_EqualAreaSpace
%
%     SYNTAX:
%    [GDDBinEdges,PrecBinEdges]=CalculateBins_CenteredSpace(GDD,Prec,Area); 
%
%

% first GDD Bins

IndicesWeCareAbout=find(CropMaskLogical & Prec < 1e15);


x=GDD(IndicesWeCareAbout);
y=Prec(IndicesWeCareAbout);
A=Area(IndicesWeCareAbout);
p=PercentToDrop/100;

[GDDBinEdges]=GetBins(x,A,N,p,'GDD');
[PrecBinEdges]=GetBins(y,A,N,p,'Prec');

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
    
    
    
    
