function used=lowerinstances(d,strings,used)
N=dir(d);
for i=1:length(N)
    if (strcmp(N(i).name,'.')+strcmp(N(i).name,'..')+strcmp(N(i).name,'.DS_Store')+strcmp(N(i).name,'.svn')==0)
    if N(i).isdir==1
        used=lowerinstances([d '/' N(i).name],strings,used);
    else if ~isempty(findstr('.m', N(i).name))
            used=lowerinstancesInFile([d '/' N(i).name],strings,used);
        end
    end
    end
end
