a=dir('YieldGap*.mat');
for j=1:length(a);
    
    load(a(j).name,'OS');
    
    FileNameBase=strrep(a(j).name,'.mat','');
    
    DAS.Units='Climate Bins';
    WriteNetCDF(single(OS.ClimateMask),'BinMatrix',[FileNameBase '_BinMatrix.nc'],DAS);
    
    DAS.Units='Climate Bins';
    WriteNetCDF(single(OS.ClimateMask),'BinMatrix',[FileNameBase '_BinMatrix.nc'],DAS);

    
    
end
