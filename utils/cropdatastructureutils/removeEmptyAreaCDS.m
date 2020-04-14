function CDSthin=removeEmptyAreaCDS(CDS);
%  remove CDS elements with no area 

c=0;
for j=1:numel(CDS)
    
    if numel(CDS(j).deepakindices)>0
        c=c+1;
        CDSthin(c)=CDS(j);
    end
end
