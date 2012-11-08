function x=fma(varargin)
% fma - alias for GetFiveMinGridCellAreas
%

if nargin==0;
    x=GetFiveMinGridCellAreas;
else
    x=GetFiveMinGridCellAreas(varargin{1:end});
end