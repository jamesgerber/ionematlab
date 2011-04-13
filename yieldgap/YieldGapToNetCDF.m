function YieldGapToNetCDF
% YieldGapToNetCDF - turn yield gap codes into a bunch of netcdfs

a=dir('YieldGap*95*10*.mat');
for j=1:length(a);
    
    load(a(j).name,'OS');
    
    FileNameBase=strrep(a(j).name,'.mat','');
    clear DAS
    
    DAS.CodeRevision=[ num2str(OS.RevData.CodeRevisionNo)];
    DAS.ProcessingDate=[ OS.RevData.ProcessingDate];
    DAS.FullFileNameKey=FileNameBase;
    
    ShortFileBase=makesafestring(['YieldGap_' OS.cropname]);
    
    DAS.Description='Climate Bins';
    WriteNetCDF(single(OS.ClimateMask),'BinMatrix',[ShortFileBase '_BinMatrix.nc'],DAS);
    
    DAS.Units='tons/ha';
    DAS.Description='Yield Potential';
    WriteNetCDF(single(OS.potentialyield),'YieldPotential',[ShortFileBase '_YieldPotential.nc'],DAS);

    MissingYield=OS.potentialyield-OS.Yield;
    MissingYield(MissingYield<0)=0;
    
    DAS.Description='Yield Gap'
    WriteNetCDF(single(MissingYield),'YieldGap',[ShortFileBase '_YieldGap.nc'],DAS);
        
end
