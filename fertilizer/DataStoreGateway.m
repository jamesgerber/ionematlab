function varargout=DataStoreGateway(name,data)
% DataStoreGateway - gateway function for fertlizermapmaking
%
%  
%  Syntax
%    DataStoreGateway(name,data);
% this will execute WriteNetCDF(appratemap,titlestr,filestr,DAS,'Force');
%
%   DS=DataStoreGateway(filestr)
%   this will execute 
%   DS=OpenNetCDF(filestr)
%

ii=CropMaskIndices;

if nargout==1
    disp(['retrieving data for ' name])
  
  load(name);
  
  data=-1*zeros(4320,2160);
  
  data(ii)=store(:);  %note that store is dataname within saved file
    varargout{1}=data;
else
    N=length(ii);
    store=data(ii);
    save(name,'store');
end
