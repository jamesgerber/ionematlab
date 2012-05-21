function x=fma(varargin)
% fma - five minute areas
%
%

if nargin==0;
    x=GetFiveMinGridCellAreas;
else
    x=GetFiveMinGridCellAreas(varargin{1:end});
end