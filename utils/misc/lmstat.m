wd=pwd;
try
    cd /Applications/MATLAB_R2009a.app/etc/
    dos(['./lmstat -a'])
    cd(wd)
catch
    try
    cd /Applications/MATLAB_R2008b.app/etc/
    dos(['./lmstat -a'])
    cd(wd)
    catch
        cd(wd)
    end
end

    
    