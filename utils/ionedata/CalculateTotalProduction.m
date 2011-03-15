function OS=CalculateTotalProduction;
% CalculateTotalProduction

C=ReadGenericCSV([iddstring '/misc/cropdata.csv']);
a=dir([iddstring '/misc/cropdata.csv']);

try
    %
    load([iddstring '/misc/TotalCropProductionData.mat'],'OS');
    
    if a.datenum > OS.cropdata_datenum
        disp(['cropdata.csv more recent than saved file.  rerunning'])
    else
       return 
    end  
catch
    disp(['unable to read ' iddstring '/misc/TotalCropProductionData.mat']);
    disp(['or it is out of date.  going to calculate it again.']);
end


cl=C.CROPNAME;

SumDryProduction=DataBlank;
SumProduction=DataBlank;
SumArea=DataBlank;

fma=GetFiveMinGridCellAreas;

for j=1:length(cl)
    %
    cl{j}
    DryFraction=C.Dry_Fraction(j);
    S=OpenNetCDF([iddstring '/Crops2000/crops/' cl{j} '_5min.nc']);
    Area=S.Data(:,:,1);
    Yield=S.Data(:,:,2);
      
    DataMask=(Area > 0 & isfinite(Area.*Yield) & Area < 9e19 & Yield < 9e19);
    
    SumProduction(DataMask)=SumProduction(DataMask)+...
        Area(DataMask).*Yield(DataMask).*fma(DataMask);
    SumDryProduction(DataMask)=SumDryProduction(DataMask)+...
        Area(DataMask).*Yield(DataMask).*fma(DataMask)*DryFraction;
    SumArea(DataMask)=SumArea(DataMask)+Area(DataMask);
end

OS.SumProduction=SumProduction;
OS.SumDryProduction=SumDryProduction;
OS.SumArea=SumArea;
OS.cropdata_datestamp=a.date;
OS.cropdata_datenum=a.datenum;

save savingPlotTotalProductionWorkspace  S
    save([iddstring '/misc/TotalCropProductionData.mat'],'OS');

   