%SystemGlobals%




MISSINGDATAVALUE=-9E9;


username=getenv('USER');

switch username
    case {'muell512','cass0131'};
        IoneDataDir=['~/Library/IonE/data/'];
    case 'jsgerber';
        IoneDataDir=['/Library/IonE/data/'];
    otherwise
        IoneDataDir=['/Library/IonE/data/'];
end

    
STANDARDWORLDMAPNAME=    'null'; % for WorldZoom, DownMap.m  
COUNTRYNAMEMAP=       'null';

ADMINBOUNDARYMAP_5min    =[IoneDataDir 'AdminBoundary2005/Raster_NetCDF/2_States_5min/glctry.nc'];
ADMINBOUNDARYMAP_5min_key=[IoneDataDir 'AdminBoundary2005/Raster_NetCDF/2_States_5min//PolitBoundary_Aug09.csv'];
% % ADMINBOUNDARYMAP_5min    =['/Users/muell512/Library/IonE/olddata/ADMINBDRY/Raster_NetCDF/2_States_5min/glctry.nc'];
% % ADMINBOUNDARYMAP_5min_key=['/Users/muell512/Library/IonE/olddata/ADMINBDRY/Raster_NetCDF/2_States_5min/PolitBoundary_Aug09.csv'];
LANDMASK_5MIN= [IoneDataDir 'LandMask/LandMaskRev1.nc'];
LANDMASK_30MIN= [IoneDataDir 'LandMask/LandMask_30min.nc'];
AREAMAP_5MIN=[IoneDataDir 'misc/area_ha_5min.nc'];
ADMINBOUNDARY_VECTORMAP=[IoneDataDir 'AdminBoundary2010/WorldLevel0Coasts_RevAr0.mat'];
DERIVEDCLIMATEDATAPATH=[IoneDataDir 'Climate/WorldClimDerivedData/'];
ADMINBOUNDARY_VECTORMAP_HIRES=[IoneDataDir 'AdminBoundary2010/WorldLevel0Coasts_RevAr0_HiRes.mat'];
USSTATESBOUNDARY_VECTORMAP_HIRES=[IoneDataDir 'AdminBoundary2010/USStates.mat'];