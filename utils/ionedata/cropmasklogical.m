function LogicalVector=cropmasklogical;
% CROPMASKLOGICAL -  logical array of standard (5 min) landmask

persistent CropLandMaskVector

if isempty(CropLandMaskVector)
    systemglobals
    [Long,Lat,Crop]=opennetcdf([iddstring '/Crops2000/Cropland2000_5min.nc']);
  %  AllIndices=1:numel(Crop);
    CropLandMaskVector=(Crop>0 & Crop < 1e10 & datamasklogical);
end
LogicalVector=CropLandMaskVector;



% function LogicalVector=cropmasklogical;
% % CROPMASKLOGICAL -  logical array of standard (5 min) landmask
% 
% persistent CropLandMaskVector
% 
% if isempty(CropLandMaskVector)
%     systemglobals
%     [Long,Lat,Data]=opennetcdf(LANDMASK_5MIN);
%     CropLandMaskVector=(Data==3)|(Data==7)|(Data>8);
% end
% LogicalVector=CropLandMaskVector;