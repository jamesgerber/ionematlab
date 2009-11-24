%SystemGlobals%




MISSINGDATAVALUE=-9E9;


username=getenv('USER');

switch username
    case 'muell512';
        IoneDataDir=['~/Library/IonE/data/'];
    case 'jsgerber';
        IoneDataDir=['/Library/IonE/data/'];
    otherwise
        IoneDataDir=['/Library/IonE/data/'];
end

    
STANDARDWORLDMAPNAME=    'null'; % for WorldZoom, DownMap.m  
COUNTRYNAMEMAP=       'null';

ADMINBOUNDARYMAP_5min    =[IoneDataDir 'AdminBoundary/glctry.nc'];
ADMINBOUNDARYMAP_5min_key=[IoneDataDir 'AdminBoundary/PolitBoundary_Aug09.csv'];
LANDMASK_5MIN= [IoneDataDir 'LandMask/LandMaskRev1.nc'];
AREAMAP_5MIN=[IoneDataDir 'misc/area_ha_5min.nc'];
ADMINBOUNDARY_VECTORMAP=[IoneDataDir 'AdminBoundary/WorldLevel0Coasts_RevAr0.mat'];
