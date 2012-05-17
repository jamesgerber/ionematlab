function LogicalVector=agrimasklogical;
% AGRIMASKLOGICAL -  logical array of standard (5 min) landmask

persistent AgriLandMaskVector

if isempty(AgriLandMaskVector)
    systemglobals
    [Long,Lat,Data]=opennetcdf(LANDMASK_5MIN);
    AgriLandMaskVector=(Data==7 | Data==3);
end
LogicalVector=AgriLandMaskVector;



