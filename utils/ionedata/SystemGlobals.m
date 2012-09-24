%SystemGlobals% -




MISSINGDATAVALUE=-9E9;


if ismac
    username=getenv('USER');
else
    username=getenv('username');
end

switch username
    case {'muell512','cass0131','oconn568','emilydombeck'   }
        IoneDataDir=['~/Library/IonE/data/'];
    case {'kbrauman'}
        IoneDataDir=['/Library/IonEdata/'];
   case 'jsgerber'
        IoneDataDir=['/Library/IonE/data/'];
    case 'mattj'
        IoneDataDir=['C:\Users\mattj\Documents\UMN\ionedata\'];
    case 'pcwest'
       IoneDataDir= '~/Data/';
    otherwise
        IoneDataDir=['/Library/IonE/data/'];
end

if ismalthus==1
    IoneDataDir=['/Library/IonE/ionedata/'];
end


ADMINBOUNDARYMAP_5min    =[IoneDataDir 'AdminBoundary2010/Raster_NetCDF/2_States_5min/glctry.nc'];
ADMINBOUNDARYMAP_5min_key=[IoneDataDir 'AdminBoundary2010/Raster_NetCDF/2_States_5min//PolitBoundary_Aug09.csv'];
LANDMASK_5MIN= [IoneDataDir 'LandMask/LandMaskRev1.nc'];
LANDMASK_30MIN= [IoneDataDir 'LandMask/LandMask_30min.nc'];
AREAMAP_5MIN=[IoneDataDir 'misc/area_ha_5min.nc'];

DERIVEDCLIMATEDATAPATH=[IoneDataDir 'Climate/WorldClimDerivedData/'];


WORLDCOUNTRIES_LEVEL0=[IoneDataDir 'AdminBoundary2010/WorldLevel0Coasts_RevAr0.mat'];

WORLDCOUNTRIES_LEVEL0_HIRES=[IoneDataDir 'AdminBoundary2010/WorldLevel0Coasts_RevAr0_HiRes.mat'];
WORLDCOUNTRIES_LEVEL1_HIRES=[IoneDataDir 'AdminBoundary2010/WorldLevel1_HiRes_RevAr0.mat'];

USSTATESBOUNDARY_VECTORMAP_HIRES=[IoneDataDir 'AdminBoundary2010/USStates.mat'];
WORLDCOUNTRIES_BRIC_NAFTASTATES_VECTORMAP_HIRES=[IoneDataDir 'AdminBoundary2010/WorldLevel0Coasts0_bricnafta1_HiRes.mat'];
%% Override settings here


ADMINBOUNDARY_VECTORMAP=WORLDCOUNTRIES_LEVEL0;
ADMINBOUNDARY_VECTORMAP_HIRES=WORLDCOUNTRIES_BRIC_NAFTASTATES_VECTORMAP_HIRES;


switch username
    case 'muell512'
        
    case 'cass0131'
        
    case 'jsgerber'
        ADMINBOUNDARYMAP_5min    =[IoneDataDir 'AdminBoundary2005/Raster_NetCDF/2_States_5min/glctry.nc'];
        ADMINBOUNDARYMAP_5min_key=[IoneDataDir 'AdminBoundary2005/Raster_NetCDF/2_States_5min//PolitBoundary_Aug09.csv'];
        
    case 'dray'
        
    case 'jfoley'
        
    otherwise
        
end