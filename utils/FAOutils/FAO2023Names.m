function Name2023=FAO2023Names(OldName);

persistent oldcodes newnames oldnames

if isempty(oldcodes)
    
    [~,verstring,CPD2024]=ReturnFAOGrossProductionValueData;
    wd=pwd;
    cd ~/DataProducts/ext/FAOstat/Production/
    CPD=ReadProductionData;
    cd(wd);
    
    
    oldcodes=unique(CPD.Item_Code);
    for j=1:numel(oldcodes);
        idx=find(CPD.Item_Code==oldcodes(j));
        oldnames{j}=CPD.Item{idx(1)};
        
        idx=find(CPD2024.Item_Code==oldcodes(j));
        if numel(idx)>0
            newnames{j}=CPD2024.Item{idx(1)};
        else
            newnames{j}='';
        end
        
    end
    
end


idx=strmatch(OldName,oldnames,'exact');
if numel(idx)==1
    Name2023=newnames{idx};
else
    Name2023='';
end





