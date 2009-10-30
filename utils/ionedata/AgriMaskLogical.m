function LogicalVector=AgriMaskLogical;
% AGRIMASKLOGICAL -  logical array of standard (5 min) landmask

persistent AgriLandMaskVector

if isempty(AgriLandMaskVector)
    SystemGlobals
    [Long,Lat,Data]=OpenNetCDF(LANDMASK_5MIN);
    AgriLandMaskVector=(Data==7 | Data==3);
end
LogicalVector=AgriLandMaskVector;



