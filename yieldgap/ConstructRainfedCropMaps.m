
for IP=[10];

for jCrop=[1 2 8 6 7 ];
    
    switch jCrop
        case 1
            name='wheat';
            CropNo=7;
        case 2
            name='maize';
            CropNo=5;
        case 8
            name='soybean'
            CropNo=13
        case 6
            name='millet'
            CropNo=17
        case 7
            name='sorghum'
            CropNo=9
    end
    
    
    ncid = netcdf.open([iddstring '/MIRCA2000_processed/mirca2000_crop' ...
        int2str(jCrop) '.nc'], 'NC_NOWRITE');
    percirrarea = netcdf.getVar(ncid,6);
    
    
    iirainfed=percirrarea<IP/100;
 
    
    S=OpenNetCDF([iddstring '/Crops2000/crops/' name '_5min.nc']);
    
    a=S.Data(:,:,1);
    y=S.Data(:,:,2);
    
    a(iirainfed)=0;
    y(iirainfed)=S.missing_value;
    
    S.Data(:,:,1)=a;
    S.Data(:,:,2)=y;
    S.Data=single(S.Data);
    
    % now write new file
    
    DAS=S;
    DAS=rmfield(DAS,'Data');
    DAS=rmfield(DAS,'Long');
    DAS=rmfield(DAS,'Lat');
    DAS.Title=['Rainfed ' name '(Irrigation < ' num2str(IP) ];
    
    writenetcdf(S.Long,S.Lat,S.Data,[name 'rainfed' num2str(IP) ],[ name 'RF' num2str(IP) '_5min.nc'],DAS)
         
end
end






