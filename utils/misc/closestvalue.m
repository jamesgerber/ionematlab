function [Val,ii]=closestvalue(y,y0);
% closestvalue - determine closest value, and index of closest value
%
%  Syntax
%
%     [value,index]=closestvalue(VectorOfValues,Value)
%
%

if nargin<2
    help(mfilename)
    return
end

if length(y0)>1;
   a=y;
   y=y0;
   y0=a;
end

[dum,ii]=min( abs(y-y0));
Val=y(ii);

