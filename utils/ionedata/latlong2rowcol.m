function [row,col]=latlong2rowcol(latpos,longpos,Lat,Long)
% latlong2rowcol - convert latitude and longitude to row and column
%
% SYNTAX
%     latlong2rowcol(latpos,longpos,Data) will return the row/col
%     associated with latpos and longpos in array Data.
%
%     latlong2rowcol(latpos,longpos,Lat,Long) will return the row/col
%     associated with latpos/longpos in a map of size Lat/Long or of size
%     length(Lat)/length(Long).
%
if nargin==3
    Long=size(Lat,1);
    Lat=size(Lat,2);
end
if ~isscalar(Long)
    Long=length(Long);
end
if ~isscalar(Lat)
    Lat=length(Lat);
end
col=round(((90.0-latpos)/180)*(Lat-1)+1);
row=round(((longpos+180.0)/360)*(Long-1)+1);
