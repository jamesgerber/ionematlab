for ibin=1:100;
    
    ii=(BinMatrix==ibin);
    
    DownSurf(Long,Lat,BinMatrix.*ii,'Climate Mask',ClimateDefs{ibin});

    set(gcf,'position',[423   641   840   378])
    addcoasts
    pause
        close(gcf)
        
end

    