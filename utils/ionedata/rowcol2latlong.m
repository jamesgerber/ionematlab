function [latpos,longpos]=rowcol2latlong(row,col,Lat,Long)
% latlong2rowcol - convert row and column to latitude and longitude
%
% SYNTAX
%     rowcol2latlong(row,col,Data) will return the lat/long
%     associated with row and col in array Data.
%
%     rowcol2latlong(row,col,Lat,Long) will return the lat/long
%     associated with row/col in a map of size Lat/Long or of size
%     length(Lat)/length(Long).
%
% EXAMPLE
% [latpos,longpos]=rowcol2latlong(5,4,10,20);
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
latpos=90-((col-1)/(Lat-1))*180;
longpos=((row-1)/(Long-1))*360-180;