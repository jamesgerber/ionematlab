function CDSthin=removeEmptyDR3Fields(CDS);
%  remove CDS elements with no DR3 field

c=0;
for j=1:numel(CDS)
    
    if ~isempty(CDS(j).DR3)
        c=c+1;
        CDSthin(c)=CDS(j);
    end
end
