function ConstructRainfedCropMaps
%  CONSTRUCTRAINFEDCROPMAPS



for IP=[10];
    
    for jCrop=[1:16 ];
        jCrop
        switch jCrop
            case 1
                name='wheat';
            case 2
                name='maize';
            case 3
                name='rice';
            case 4
                name='barley';
            case 5
                name='rye';
            case 6
                name='millet'
            case 7
                name='sorghum'
            case 8
                name='soybean'
            case 9
                name='sunflower';
            case 10
                name='potato';
            case 11
                name='cassava';
            case 12
                name='sugarcane';
            case 13
                name='sugarbeet';
            case 14
                name='oilpalm';
            case 15
                name='rapeseed';
            case 16
                name='groundnut';
 
        end
        
%         
%         1	Wheat
% 2	Maize
% 3	Rice
% 4	Barley
% 5	Rye
% 6	Millet
% 7	Sorghum
% 8	Soybeans
% 9	Sunflower
% 10	Potatoes
% 11	Cassava
% 12	Sugar cane
% 13	Sugar beets
% 14	Oil palm
% 15	Rapeseed / Canola
% 16	Groundnuts / Peanuts
% 17	Pulses
% 18	Citrus
% 19	Date palm
% 20	Grapes / Vine
% 21	Cotton
% 22	Cocoa
% 23	Coffee
%         
        
        
        DataYear=2005;
        
        ncid = netcdf.open([iddstring '/MIRCA2000_processed/mirca2000_crop' ...
            int2str(jCrop) '.nc'], 'NC_NOWRITE');
        percirrarea = netcdf.getVar(ncid,6);
        
        iirainfed=percirrarea<IP/100;
        ii_irr=percirrarea>=IP/100;
        disp(['Number of rainfed points / cutoff=' num2str(IP) ])
        length(find(iirainfed))
        
    %    S=OpenNetCDF([iddstring '/Crops2000/crops/' name '_5min.nc']);
        S=getcropdata(name,2005);
        %% Rainfed crops
        a=S.Data(:,:,1);
        y=S.Data(:,:,2);
        
        
        iiareabig=(a>9e9);
                
        a(ii_irr)=0;
        a(iiareabig)=S.missing_value;
        y(ii_irr)=S.missing_value;
        
        S.Data(:,:,1)=a;
        S.Data(:,:,2)=y;
        S.Data=single(S.Data);
        
        % now write new file
        
        DAS=S;
        DAS=rmfield(DAS,'Data');
        DAS=rmfield(DAS,'Long');
        DAS=rmfield(DAS,'Lat');
        DAS.Title=['Rainfed ' name '(Irrigation < ' num2str(IP) ];
        DAS.Description1=' 2005 Data but 2000 MIRCA irrigation data ';
        writenetcdf(S.Long,S.Lat,S.Data,[name 'rainfed' num2str(IP) ],[ name 'RF' num2str(IP) '_' int2str(DataYear) '_5min.nc'],DAS)
        %%  Irrigated crops
        S=OpenNetCDF([iddstring '/Crops2000/crops/' name '_5min.nc']);
        a=S.Data(:,:,1);
        y=S.Data(:,:,2);
       
        
        iiareabig=(a>9e9);
                
        a(iirainfed)=0;
        a(iiareabig)=S.missing_value;
        y(iirainfed)=S.missing_value;
        
        S.Data(:,:,1)=a;
        S.Data(:,:,2)=y;
        S.Data=single(S.Data);
        
        % now write new file
        
        DAS=S;
        DAS=rmfield(DAS,'Data');
        DAS=rmfield(DAS,'Long');
        DAS=rmfield(DAS,'Lat');
        DAS.Title=['Irrigated ' name '(Irrigation > ' num2str(IP) ];
        
        writenetcdf(S.Long,S.Lat,S.Data,[name 'irrigated' num2str(IP) ],[ name 'IRR' num2str(IP) '_' int2str(DataYear) '_5min.nc'],DAS)
    end
end






