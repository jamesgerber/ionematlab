function [lats lons]=getlatlon(data,latextent,lonextent)
% getlatlon - create lat and lon vectors
%
% SYNTAX
% [lats lons]=getlatlon(data) will return lat and lon vectors matching the
% resolution of data and assuming that data's extent is the entire world
% 
% [lats lons]=getlatlon(data,latextent,lonextent) uses latextent and
% lonextent for the extent of data
%
% latextent and lonextent may be ascending or descending. The actual
% content of data is never examined, just its size.
%
% EXAMPLE
% [lats lons]=getlatlon(magic(5))
%

if (nargin==1)
    lonextent=[-180,180];
    latextent=[90,-90];
end
lonoffset=(lonextent(2)-lonextent(1))/size(data,1);
lons(:,1)=(lonextent(1)+lonoffset/2):lonoffset:(lonextent(2)-lonoffset/2);
latoffset=(latextent(2)-latextent(1))/size(data,2);
lats(:,1)=(latextent(1)+latoffset/2):latoffset:(latextent(2)-latoffset/2);