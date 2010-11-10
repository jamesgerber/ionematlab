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

if nargout==1
    disp(['retrieving data for ' name])
  
  load(name);
  
  tmp = length(store);
  switch tmp
      case 2069588
          ii = AgriMaskIndices;
      case 920953
          ii = CropMaskIndices;
  end
    
  data=-1*nan(4320,2160);
  
  data(ii)=store(:);  %note that store is dataname within saved file
    varargout{1}=data;
else
    ii=CropMaskIndices;
    N=length(ii);
    store=data(ii);
    save(name,'store');
end
