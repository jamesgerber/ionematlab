function [row,col]=LatLong2RowCol(latpos,longpos,Lat,Long)
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
