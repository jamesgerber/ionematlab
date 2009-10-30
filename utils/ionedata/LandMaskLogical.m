function LogicalVector=LandMaskLogical;
% LANDMASKLOGICAL -  logical array of standard (5 min) landmask

persistent LogicalLandMaskVector

if isempty(LogicalLandMaskVector)
    SystemGlobals
    [Long,Lat,Data]=OpenNetCDF(LANDMASK_5MIN);
    LogicalLandMaskVector=(Data>0);
end
LogicalVector=LogicalLandMaskVector;



