function DataStructure=DataStoreGateway(varargin)
% DataStoreGateway - gateway function for fertlizermapmaking
%
%  
%  Syntax
%    DataStoreGateway(appratemap,titlestr,filestr,DAS,'Force');
% this will execute WriteNetCDF(appratemap,titlestr,filestr,DAS,'Force');
%
%   DS=DataStoreGateway(filestr)
%   this will execute 
%   DS=OpenNetCDF(filestr)
%
if nargout==0
  disp(['storing data for ' titlestr])
  appratemap=varargin{1};
    titlestr=varargin{2};
    filestr=varargin{3};
    DAS=varargin{4};
    'Force'=varargin{5};
    WriteNetCDF(appratemap,titlestr,filestr,DAS,'Force');
else
  disp(['retrieving data for ' titlestr])
  filestr=varargin{1};
  DataStructure = OpenNetCDF(filestr);
end
