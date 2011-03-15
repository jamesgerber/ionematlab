function ConvertNetCDFs2mat
% ConvertNetCDFs2mat - recursively save .nc to .mat / gzip the .nc
%
pwd
a=dir;

for j=3:length(a)  %first two are self/parent dir
    
    if a(j).isdir
        cd(a(j).name)
        ConvertNetCDFs2mat
        cd ../
    else
        thisname=a(j).name;
        if length(thisname) >3 & isequal(thisname(end-2:end),'.nc')
            disp(['converting ' thisname]);
            S=OpenNetCDF(thisname);
            disp(['compressing ' thisname]);
            dos(['gzip ' thisname])
        end
    end
end