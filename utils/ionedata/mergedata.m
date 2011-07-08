function A=mergedata(background,blon,blat,data,dlon,dlat,method)
%  mergedata - paste data onto background
%
%  AddStates(background,blon,blat,data,dlon,dlat), where background is some
%  background data like a global land mask, with longitude and latitude
%  defined by blon and blat, and data is an array to be pasted on top of it
%  with latitude and longitude defined by dlon and dlat, will put data over
%  background such that the resulting array will have the same extent and
%  same lat-long values as background. The extent of data must be within
%  the extent of background. NaNs within data will be treated as
%  transparent and will not be pasted.
%

if (nargin<7)
    method='nearest';
end
[~,ilon1]=nearestelement(blon,min(dlon));
[~,ilon2]=nearestelement(blon,max(dlon));
numlon=abs(ilon1-ilon2)+1;
[~,ilat1]=nearestelement(blat,min(dlat));
[~,ilat2]=nearestelement(blat,max(dlat));
numlat=abs(ilat1-ilat2)+1;
data=easyinterp2(data,numlon,numlat,method);
if (ilon1>ilon2)
    tmp=ilon1;
    ilon1=ilon2;
    ilon2=tmp;
end
if (ilat1>ilat2)
    tmp=ilat1;
    ilat1=ilat2;
    ilat2=tmp;
end
tmp=background;
background(ilon1:ilon2,ilat1:ilat2)=data;
background(isnan(background))=tmp(isnan(background));
A=background;