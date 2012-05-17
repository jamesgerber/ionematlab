function newmap=stretchcolormap(cmap,cmin,cmax,center);
%  stretchcolormap - stretch out a colormap 
%
%     Use this if data goes from negative to positive but isn't
%     centered
%
%   Example
%
%   M=getdata('maize');
%   W=getdata('wheat');
%   DelYield=M.Data(:,:,2)-W.Data(:,:,2);  %meaningless data
%   clear NSS
%   NSS.FastPlot='on';
%   NSS.colormap='orange_white_purple_deep';
%   NSS.caxis=[-5 15];
%   nicesurfGeneral(DelYield,NSS)
%   cmap=finemap('orange_white_purple_deep','','');
%   NewMap=stretchcolormap(cmap,-5,15);
%   NSS.caxis=[-5 15];
%   NSS.colormap=NewMap;
%   nicesurfGeneral(DelYield,NSS)
%

if nargin<4
    center=0;
end
if (cmin-center)*(cmax-center) > 0
  error([' cmin cmax the same sign.']);
end


if cmin > cmax
  error
end

if ischar(cmap)
    cmap=finemap(cmap,'','');
end

[N,~]=size(cmap);

mid=round(N/2);

neg= -(cmin-center)/(cmax-cmin);
pos= (cmax-center)/(cmax-cmin);

cmapneg=cmap(1:mid,1:3);
cmappos=cmap(mid:end,1:3);


if neg/pos > 1
  % more negative than positive.
  % don't touch the neg values, remove some of the pos values
  
  ii=floor(linspace(mid,N,mid*(pos/neg)));
  tmp=cmap(ii,1:3);
  newmap=[cmapneg ; tmp];
else

 ii=floor(linspace(1,mid,mid*(neg/pos)));
  tmp=cmap(ii,1:3);
  newmap=[tmp; cmappos];
end