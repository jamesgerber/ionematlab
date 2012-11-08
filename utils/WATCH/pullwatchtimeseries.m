function [mdn,ts]=pullwatchtimeseries(idx,basedir);
% pullwatchtimeseries


idx=1:1000;
basedir=[iddstring '/Climate/reanalysis/WATCH/Tair_WFD/'];


for mm=1:12
    for yy=1902:2000;
        FileName=[basedir 'Tair_WFD_' int2str(yy) int2str(mm) '.nc']
        S=OpenGeneralNetCDF(FileName);
        
        keyboard
    end
end

        