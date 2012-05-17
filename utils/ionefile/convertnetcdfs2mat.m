function convertnetcdfs2mat
% convertnetcdfs2mat - recursively save .nc to .mat / gzip the .nc
%
% See Also opennetcdf
pwd
a=dir;

for j=3:length(a)  %first two are self/parent dir
    
    if a(j).isdir
        cd(a(j).name)
        convertnetcdfs2mat
        cd ../
    else
        thisname=a(j).name;
        if length(thisname) >3 & isequal(thisname(end-2:end),'.nc')
            disp(['converting ' thisname]);
            S=opennetcdf(thisname);
            disp(['compressing ' thisname]);
            dos(['gzip -f ' thisname])
        end
    end
end