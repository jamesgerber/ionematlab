function ygpatchplot(CDS,Vector)
% YGPatchPlot - make a patch plot given a vector and a CDS structure
%
%  
for ibin=1:length(CDS)

  S=CDS(ibin);
  x(1)=S.GDDmin;
  x(2)=S.GDDmin;
  x(3)=S.GDDmax;
  x(4)=S.GDDmax;  
  x(5)=S.GDDmin;    
  
  y(1)=S.Precmin;
  y(2)=S.Precmax;  
  y(3)=S.Precmax;    
  y(4)=S.Precmin;  
  y(5)=S.Precmin;       
  x=double(x);y=double(y);
 
  patch(x,y,Vector(ibin));
end