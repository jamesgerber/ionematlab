function [row,col]=LatLong2RowCol(latpos,longpos,Lat,Long)
% LatLong2RowCol - convert latitude and longitude to row and column
%
% SYNTAX
%     LatLong2RowCol(latpos,longpos,Data) will return the row/col
%     associated with latpos and longpos in array Data.
%
%     LatLong2RowCol(latpos,longpos,Lat,Long) will return the row/col
%     associated with a map of size Lat/Long or of size
%     length(Lat)/length(Long).
%
if nargin==3
    Long=max(size(Lat));
    Lat=min(size(Lat));
end
if ~isscalar(Long)
    Long=length(Long);
end
if ~isscalar(Lat)
    Lat=length(Lat);
end
col=round(((90.0-latpos)/180)*(Lat-1)+1);
row=round(((longpos+180.0)/360)*(Long-1)+1);
