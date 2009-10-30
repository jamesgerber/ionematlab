function [jp,xbins,ybins]=GenerateJointDist(X,Y,XBinEdges,YBinEdges);
% GENERATEJOINTDIST - Generate joint distribution of two vectors
%  [jp,xbins,ybins]=GenerateJointDist(X,Y,XBinEdges,YBinEdges);
%
%
%  Syntax Notes:
%
%      X and Y must be vectors of equal length
%      XBinEdges (and YBinEdges) may be given as a number N.  If this is
%      the case, then the hist command will be used to determine N equally
%      spaced bins.
%
%      jp is the joint probability distribution
%      xbins is a vector denoting the centers of the bins.  so
%      length(xbins)=length(XBinEdges)-1 
%
%   See Also:  SelectUniformBins
%
 
if nargin==0
    help(mfilename)
    return
end

if nargin==2
    XBinEdges=10;
    YBinEdges=10;
end

if length(XBinEdges)==1
  [N,XBinEdges]=hist(X,XBinEdges);
  XBinEdges(end+1)=XBinEdges(end)+ (XBinEdges(end)-XBinEdges(end-1));
end

if length(YBinEdges)==1
  [N,YBinEdges]=hist(Y,YBinEdges);
  YBinEdges(end+1)=YBinEdges(end)+ (YBinEdges(end)-YBinEdges(end-1));
end


NX=length(XBinEdges)-1;
NY=length(YBinEdges)-1;

for j=1:NX;
   ii=find( X>(XBinEdges(j)) & X<=(XBinEdges(j+1)));
   [N]=histc(Y(ii),YBinEdges);  %want a column vector
   jp(j,1:NY)=N(1:end-1);
end


xbins=(XBinEdges(1:end-1)+XBinEdges(2:end))/2;
ybins=(YBinEdges(1:end-1)+YBinEdges(2:end))/2;


if nargout==0
    figure
    set(gcf,'renderer','zbuffer')
    cs=surface(xbins,ybins,jp.');
    colorbar
    title('Joint distribution')
    shading flat

end
