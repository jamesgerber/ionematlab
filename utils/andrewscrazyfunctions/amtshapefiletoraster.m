function [R,names,areaPoly,areaRaster]=shapefileToRaster(filename,nameField,density,latlim,lonlim)
% SHAPEFILETORASTER - open a shapefile and convert it to a raster
% 
% SYNTAX
% [R,names,areaPoly,areaRaster]=shapefileToRaster(filename,nameField,density,latlim,lonlim)
%   filename may be the name of a shapefile or a shapefile structure from
%   shaperead. nameField is the field that corresponds to the name of each
%   polygon; if empty, names will not be returned. density is the number of
%   cells per degree (or other distance unit), latlim is a 2-element vector
%   [southlimit, northlimit], and lonlim is [eastlimit,westlimit].
%
%   By default, nameField is empty, density is 12, latlim is [-90, 90], and
%   lonlim is [-180, 180];
if nargin<3
    density=12;
end
if nargin<2
    nameField=[];
end
if nargin<5
    latlim=[-90 90];
    lonlim=[-180 180];
end
if (isstruct(filename))
    S=filename;
else
    S=shaperead(filename);
end
try
    S.Y=S.Lat;
    S.X=S.Lon;
end
try
    S.Y=S.LAT;
    S.X=S.LON;
end
try
    S.Y=S.lat;
    S.X=S.lon;
end
try
    S.Y=S.Lat;
    S.X=S.Long;
end
try
    S.Y=S.LAT;
    S.X=S.LONG;
end
try
    S.Y=S.lat;
    S.X=S.long;
end
R=zeros((lonlim(2)-lonlim(1))*density,(latlim(2)-latlim(1))*density);
areaPoly=zeros(length(S),1);
areaRaster=zeros(length(S),1);
names=cell(length(S),1);
for i=1:length(S)
    disp(filename);
    disp(i/length(S));
    T=flipud(vec2mtx(S(i,1).Y,S(i,1).X,density,latlim,lonlim,'filled'))';
    R((R==0)&(T<2))=i;
    if (~isempty(nameField))
        names{i}=eval(['S(i,1).' nameField ';']);
    end
end

for i=1:length(S)
    areaPoly(i,1)=sum(areaint(S(i,1).Y,S(i,1).X,[1 0]));
    areaRaster(i,1)=sum(areamat((R==i)',[12 90 -180],[1 0]));
end