function [GDDBinEdges,PrecBinEdges]= ...
    CalculateBins_CenteredSpace(GDD,Prec,Area,N,PercentToDrop);
%   CalculateBins_CenteredSpace
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

[GDDBinEdges]=GetBins(x,A,N,p);
[PrecBinEdges]=GetBins(y,A,N,p);

function [xbins]=GetBins(x,y,N,p);
[xsort,ii]=sort(x);

ysort=y(ii);

ysum=cumsum(ysort);
ysumnorm=ysum/max(ysum);

i5=min(find(ysumnorm>=p));
i95=max(find(ysumnorm<=(1-p)));

x5=xsort(i5);
x95=xsort(i95);

xbins=[min(x) linspace(x5,x95,(N-1)) max(xsort)];
