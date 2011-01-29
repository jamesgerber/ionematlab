% cropnc_to_mat

%Read in crop .ncs and write mat files ... easier to read

wd=pwd;

try
    
    cd([iddstring '/Crops2000/crops']);
    
    a=dir('*.nc');
    
    for j=1:length(a)
        S=OpenNetCDF(a(j).name)
        reducedname=strrep(a(j).name,'.nc','.mat');
        Area=S.Data(:,:,1);
        Yield=S.Data(:,:,2);
        
        AreaCropMask=Area(CropMaskIndices);
        YieldCropMask=Yield(CropMaskIndices);
        save(['../crops_mat/' reducedname],'S','AreaCropMask','YieldCropMask')
    end
    
catch
    cd(wd)
end

