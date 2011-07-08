function A=mergedata(background,blon,blat,data,dlon,dlat,method)
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
size(data)
ilon1
ilon2
ilat1
ilat2
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
background(ilon1:ilon2,ilat1:ilat2)=data;
A=background;