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
if nargin==0 | nargout==0
  help(mfilename)
  return
end

if nargin<1
    matrixflag=0;
end


SystemGlobals
switch lower(DataString)
 case 'tmi'
  S=OpenNetCDF([IoneDataDir 'Climate/' ...
		    'WorldClimDerivedData/TMI.nc']);
 case 'gdd0'
  S=OpenNetCDF([IoneDataDir 'Climate/' ...
		    'WorldClimDerivedData/GDD0.nc']);
 case 'totc1'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_LevelD1']);    
 
  case 'totc2'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_LevelD2']);    
 
  case 'totc3'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_LevelD3']);    
 
  case 'totc4'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_LevelD4']);    
 
  case 'totc5'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_LevelD5']);    
 
    case {'totc_30','c30'}
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_30']);    

    case {'totc_avg','totc'}
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/TOTC_avg']);    

  case 'bulk1'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/BULK_LevelD1']);    
 
  case 'bulk2'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/BULK_LevelD2']);    
 
  case 'bulk3'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/BULK_LevelD3']);    
 
  case 'bulk4'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/BULK_LevelD4']);    
 
  case 'bulk5'
  S=OpenNetCDF([IoneDataDir 'ISRICProcessed/BULK_LevelD5']);    
 
 otherwise
  error([' haven''t coded in ' DataString]);
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
  varargout{1}=S.Long;
  varargout{2}=S.Lat;
  varargout{3}=S.Data;  
end
