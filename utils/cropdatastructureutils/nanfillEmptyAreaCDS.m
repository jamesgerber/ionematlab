function CDSthin=nanfillEmptyAreaCDS(CDS);
%  remove CDS elements with no area  - not yet written

c=0;
for j=1:numel(CDS)
    
    if numel(CDS(j).deepakindices)==0
        C=CDS(j);
        error not done 
        
        
        CDSthin(c)=CDS(j);
    end
end
