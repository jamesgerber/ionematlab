function varargout=OpenNetCDF(FileName);
% OPENNETCDF - Open a long/lat/data netcdf file
%
%  Syntax
%
%    [Long,Lat,Data]=OpenNetCDF;
%
%    [DS]=OpenNetCDF   Will return just a data structure.
%
%
%    [Long,Lat,Data]=OpenNetCDF(FileName);
%
%
%   See also OPENGENERALNETCDF, WRITENETCDF
if nargout==0
    help(mfilename)
    return
end

if nargin==0
    [filename,pathname]=uigetfile('*.nc','Pick a NetCDF file');
    FileName=[pathname filesep filename];
end

%% OpenFile
ncid=netcdf.open(FileName,'NOWRITE');

% some checks to make sure that this is the standard format

[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

if ndims~=4
    error('not expected type of file: ndims ~=4.  Try OpenGeneralNETCDF')
end

if nvars~=5
    error('not expected type of file: nvars ~=5.  Try OpenGeneralNETCDF')
end

Var0Name=netcdf.inqDim(ncid,0);
Var1Name=netcdf.inqDim(ncid,1);

if ~strcmp(lower(Var0Name(1:3)),'lon');
    error('Dimension 0 is not longitude.  Try OpenGeneralNETCDF')
end

if ~strcmp(lower(Var1Name(1:3)),'lat');
    error('Dimension 1 is not longitude.  Try OpenGeneralNETCDF')
end


ncid=netcdf.open(FileName,'NOWRITE');
Long=netcdf.GetVar(ncid,0);
Lat=netcdf.GetVar(ncid,1);
Data=netcdf.GetVar(ncid,4);

switch nargout
    case 1
        DS.Data=Data;
        DS.Long=Long;
        DS.Lat=Lat;
        DS.units='';
        try
            DataVarName=netcdf.inqVar(ncid,4);
            DS.Title=DataVarName;
            
            for j=0:1000 % this will crash, but we are in a try statement
                ThisName=netcdf.inqAttName(ncid,4,j);
                
                
                ThisValue=netcdf.getAtt(ncid,4,ThisName);
                
                if isequal(ThisName(1),'_')
                    ThisName=ThisName(2:end);
                end
                DS=setfield(DS,lower(ThisName),ThisValue);
            end
        catch
            DS.Title=FileName;
        end
        
        
        varargout{1}=DS;
    case 3
        varargout{1}=Long;
        varargout{2}=Lat;
        varargout{3}=Data;
    otherwise
        error
end

netcdf.close(ncid);
