function LogicalVector=CropMaskLogical;
% CROPMASKLOGICAL -  logical array of standard (5 min) landmask

persistent CropLandMaskVector

if isempty(CropLandMaskVector)
    SystemGlobals
    [Long,Lat,Data]=OpenNetCDF(LANDMASK_5MIN);
    CropLandMaskVector=(Data==3)|(Data==7)|(Data>8);
end
LogicalVector=CropLandMaskVector;