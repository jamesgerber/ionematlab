function varargout=getdata(DataString,matrixflag);
% GETDATA - Get IONE data
%
%  Syntax
%
%   [Long,Lat,Data]=getdata(DataString)
%
%   [S]=getdata(DataString)
%
%   [S]=getdata(DataString,matrixflag)
%
%   [Data]=getdata(DataString,1)
%
%   If there are three outputs, matrixflag will be ignored.
%
%  Example
%
%    [Long,Lat,Crop]=getdata('croparea');
%    [Long,Lat,totc]=getdata('totc1');
%
%  if DataString is a crop, and there are three output arguments
%   [CropStruct,area,yield]=getdata('croparea');
if nargin==0 | nargout==0
    help(mfilename)
    return
end

if nargin<1
    matrixflag=0;
end

iscrop=0;

systemglobals
switch lower(DataString)
    case {'croparea','cropdata'}
        S=opennetcdf([iddstring 'Crops2000/' ...
            'Cropland2000_5min.nc']);
   case {'pastarea','pasture'}
        S=opennetcdf([iddstring 'Crops2000/' ...
            'Pasture2000_5min.nc']);
        
    case 'tmi'
        S=opennetcdf([IoneDataDir 'Climate/' ...
            'WorldClimDerivedData/TMI.nc']);
        
    case 'gdd0'
        S=opennetcdf([IoneDataDir 'Climate/' ...
            'WorldClimDerivedData/GDD0.nc']);
    case 'totc1'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_LevelD1']);
        
    case 'totc2'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_LevelD2']);
        
    case 'totc3'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_LevelD3']);
        
    case 'totc4'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_LevelD4']);
        
    case 'totc5'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_LevelD5']);
        
    case {'totc_30','c30'}
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_30']);
        
    case {'totc_avg','totc'}
        S=opennetcdf([IoneDataDir 'ISRICProcessed/TOTC_avg']);
        
    case 'bulk1'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/BULK_LevelD1']);
        
    case 'bulk2'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/BULK_LevelD2']);
        
    case 'bulk3'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/BULK_LevelD3']);
        
    case 'bulk4'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/BULK_LevelD4']);
        
    case 'bulk5'
        S=opennetcdf([IoneDataDir 'ISRICProcessed/BULK_LevelD5']);
        
    case {'percapitagdp'}
        S=opennetcdf([IoneDataDir 'misc/PerCapitaGDPv10.nc']);
        
        
    case {'hwsd_categoricalcsqi','categoricalcsqi','csqi'}
        S=opennetcdf([IoneDataDir 'harmonisedsoils/HWSD_CategoricalCSQI.nc']);
        
    case {'hwsd_categoricalcsqi_ar1'}
        S=opennetcdf([IoneDataDir 'harmonisedsoils/HWSD_CategoricalCSQI_Ar1.nc']);
        
    case {'hwsd_categoricalcsqi_ar2'}
        S=opennetcdf([IoneDataDir 'harmonisedsoils/HWSD_CategoricalCSQI_Ar2.nc']);
        
    case {'hwsd_categoricalcsqi_br1'}
        S=opennetcdf([IoneDataDir 'harmonisedsoils/HWSD_CategoricalCSQI_br1.nc']);
        
    case {'hwsd_categoricalcsqi_br2'}
        S=opennetcdf([IoneDataDir 'harmonisedsoils/HWSD_CategoricalCSQI_br2.nc']);
        
    otherwise
        %%%% assume that this is a cropname
        try
            S=opennetcdf([iddstring '/Crops2000/crops/' DataString '_5min.nc']);
            iscrop=1;
        catch
            error([' haven''t coded in ' DataString]);
        end
end

if nargin==2
    if matrixflag==1
        S=S.Data;
    end
end

switch nargout
    case 1
        varargout{1}=S;
    case 3
        if iscrop==0
            varargout{1}=S.Long;
            varargout{2}=S.Lat;
            varargout{3}=S.Data;
        else
            varargout{1}=S;
            ii=gooddataindices(S);
            tmp=S.Data(:,:,1);
            tmp(~ii)=NaN;
            varargout{2}=tmp;
            tmp=S.Data(:,:,2);
            tmp(~ii)=NaN;
            varargout{3}=tmp;
        end
        
end
