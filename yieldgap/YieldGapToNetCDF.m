a=dir('YieldGap*95*10*.mat');
for j=1:length(a);
    
    load(a(j).name,'OS');
    
    FileNameBase=strrep(a(j).name,'.mat','');
    clear DAS
    
    DAS.CodeRevision=[ num2str(OS.RevData.CodeRevisionNo)];
    DAS.ProcessingData=[ OS.RevData.ProcessingDate];

    DAS.Description='Climate Bins';
    WriteNetCDF(single(OS.ClimateMask),'BinMatrix',[FileNameBase '_BinMatrix.nc'],DAS);
    
    DAS.Units='tons/ha';
    DAS.Description='Yield Potential';
    WriteNetCDF(single(OS.ClimateMask),'YieldPotential',[FileNameBase '_YieldPotential.nc'],DAS);

    MissingYield=OS.potentialyield-OS.Yield;
    MissingYield(MissingYield<0)=0;
    
    DAS.Description='Yield Gap'
    WriteNetCDF(single(OS.ClimateMask),'YieldGap',[FileNameBase '_YieldGap.nc'],DAS);
        
end
