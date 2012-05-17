function x=fma(varargin)
% fma - five minute areas
%
%

if nargin==0;
    x=getfivemingridcellareas;
else
    x=getfivemingridcellareas(varargin{1:end});
end