function LogicalVector=CropMaskLogical;
% CROPMASKLOGICAL -  logical array of standard (5 min) landmask

persistent CropLandMaskVector

if isempty(CropLandMaskVector)
    SystemGlobals
    [Long,Lat,Crop]=OpenNetCDF('/Library/IonE/data/Cropland2000_5min.nc');
  %  AllIndices=1:numel(Crop);
    CropLandMaskVector=(Crop>0 & Crop < 1e10 & DataMaskLogical);
end
LogicalVector=CropLandMaskVector;



