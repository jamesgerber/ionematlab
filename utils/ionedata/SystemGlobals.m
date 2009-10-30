%function SystemGlobals%%

STANDARDWORLDMAPNAME=    'null'; % for WorldZoom, DownMap.m  
ADMINBOUNDARYMAP_5min    ='/Library/IonE/data/AdminBoundary/glctry.nc';
ADMINBOUNDARYMAP_5min_key='/Library/IonE/data/AdminBoundary/PolitBoundary_Aug09.csv';
COUNTRYNAMEMAP=       'null';
LANDMASK_5MIN= '/Library/IonE/data/LandMask/LandMaskRev1.nc';

MISSINGDATAVALUE=-9E9;
%% OCEAN MASK.  
OCEANMASKDATA=        'null';   
  %DataLat       2160x1                   8640  single              
  %DataLong      4320x1                  17280  single              
  %MaskData      4320x2160            74649600  double           

username=getenv('USER');
if username=='muell512'
    disp('This is where Nathan overrides all default settings.')
end

    