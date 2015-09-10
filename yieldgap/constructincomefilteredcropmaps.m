function ConstructIncomeFilteredCropMaps
%  CONSTRUCTINCOMEFILTEREDCROPMAPS

for CropNo=[1];
    
    switch CropNo
        case 7
            name='wheat';
        case 5
            name='maize';
        case 13
            name='soybean';
        case 17
            name='millet'
        case 9
            name='sorghum'
        case 1
            name='rice'
    end
    
    
    
    
    
    S=OpenNetCDF([iddstring '/Crops2000/crops/' name '_5min.nc']);
    
    a=S.Data(:,:,1);
    y=S.Data(:,:,2);
    
    
    
    for Income=[1 2 ];
        
        
        switch Income
            case 1
                %% High income
                ii=getOECDincomeoutline('high');
                NameBase='HiIncome';
            case 2
                %% Lo income
                iihi=getOECDincomeoutline('high');              
                ii=landmasklogical & ~iihi;               
                NameBase='LoIncome';
                
        end
        
        a(~ii & DataMaskLogical)=0;
        y(~ii)=S.missing_value;
        
        S.Data(:,:,1)=a;
        S.Data(:,:,2)=y;
        S.Data=single(S.Data);
        
        % now write new file
        
        DAS=S;
        DAS=rmfield(DAS,'Data');
        DAS=rmfield(DAS,'Long');
        DAS=rmfield(DAS,'Lat');
        DAS.Title=[NameBase name  ];
        
        writenetcdf(S.Long,S.Lat,S.Data,[name NameBase ],[ name NameBase '_5min.nc'],DAS)
        
    end
end

return


%% test code to split up income areas
M=getdata('maize');
a=M.Data(:,:,1);
y=M.Data(:,:,2);
a(a>5)=0;
a=a.*GetFiveMinGridCellAreas;


ii_lo=getOECDincomeoutline('low');
ii_um=getOECDincomeoutline('um');
ii_lm=getOECDincomeoutline('lm');
ii_hi=getOECDincomeoutline('high');
ii_non=getOECDincomeoutline('high_non');


sum(a(ii_hi))/1e6
sum(a(ii_um))/1e6
sum(a(ii_lm))/1e6
sum(a(ii_lo))/1e6
sum(a(ii_non))/1e6

S=getdata('soybean');
a=S.Data(:,:,1);
y=S.Data(:,:,2);
a(a>5)=0;
a=a.*GetFiveMinGridCellAreas;

sum(a(ii_hi))/1e6
sum(a(ii_um))/1e6
sum(a(ii_lm))/1e6
sum(a(ii_lo))/1e6
sum(a(ii_non))/1e6


