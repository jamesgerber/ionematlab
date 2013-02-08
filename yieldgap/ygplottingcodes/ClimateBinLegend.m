function Cbl(CDS,colors,titlestring);

N=sqrt(length(CDS));


  figure
axes

  
x=1:N;
y=1:N;
for j=1:N
    for k=1:N
        m=(j-1)*N+k;
        
        S=CDS(m);
        xvect=[S.GDDmin S.GDDmax S.GDDmax S.GDDmin];
        yvect=[S.Precmin S.Precmin S.Precmax S.Precmax];
        
        
        patch(xvect,yvect,colors(j,k).rgb);
        
    end
end


set(gca,'visib','off')

  figure
axes

  
x=1:N;
y=1:N;
for j=1:N
    for k=1:N
        m=(j-1)*N+k;
        
        S=CDS(m);
        xvect=[S.GDDmin S.GDDmax S.GDDmax S.GDDmin];
        yvect=[S.Precmin S.Precmin S.Precmax S.Precmax];
        
        
        patch(xvect,yvect,colors(j,k).rgb);
        
    end
end
xlabel('GDD')
ylabel('Precip')
title(titlestring)
