% this is the script that was used to create WFDgrid.mat, which is used by embedWFDvector
S=OpenGeneralNetCDF('WFD-land-lat-long-z.nc');

longvals=S(1).Data;
longvals_int=S(4).Data;

latvals=S(2).Data;
latvals_int=S(5).Data;

land=S(3).Data;
z=S(6).Data;

gridmat=datablank(0,'30min');
zmat=datablank(0,'30min');
landmat=datablank(0,'30min');

gx=[1:720];
gy=[1:360];

for j=1:length(z);
    
   x=longvals(j)
y=latvals(j)
 
    
x=longvals_int(j);
y=latvals_int(j);

ix=find(gx==x);
iy=find(gy==y);

gridmat(ix,iy)=j;
zmat(ix,iy)=z(j);
landmat(ix,iy)=land(j);
end



for j=1:67420
    ii=find(WFDgrid==j);
    iivect(j)=ii;
end


WFDgrid=gridmat;

save WFDgrid WFDgrid zmat landmat iivect