function PotentialYieldSurfaceInClimateSpace(OS);

expandstructure(OS)
for j=1:length(CDS);
  GDDVect(j)=mean([CDS(j).GDDmin CDS(j).GDDmax]);
  PrecVect(j)=mean([CDS(j).Precmin CDS(j).Precmax]);  
  PYVect(j)=VectorOfPotentialYields(j);
end

scatter3(GDDVect,PrecVect,PYVect)

xlabel('GDD')
ylabel('prec')
zlabel('tons/ha')



N=sqrt(length(CDS));
for j=1:N
  for m=1:N
    k=(N*(j-1))+m;
    GDDMat(j,m)=double(GDDVect(k));
    PrecMat(j,m)=double(PrecVect(k));    
    PYMat(j,m)=double(PYVect(k));    
  end
end

figure
mesh(GDDMat,PrecMat,PYMat);


  