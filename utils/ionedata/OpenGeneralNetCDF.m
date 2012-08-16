function Svector=OpenGeneralNetCDF(FileName)
% OPENGENERALNETCDF - Open a general netcdf file
%
%  Syntax
%
%    S=OpenGeneralNetCDF(FileName) will pull all data out of a netcdf file.
%
%
%  See also OpenNetCDF
if (nargin==0 && nargout~=1)    
    help(mfilename)
    Svector=[];
    return
end

if nargin==0
    [filename,pathname]=uigetfile('*.nc','Pick a NetCDF file');
    FileName=[pathname filesep filename];
end

%% OpenFile
ncid=netcdf.open(FileName,'NOWRITE');

[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

for varid=0:nvars-1
    c=varid+1;
    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
    S.varname=varname;
    S.Data=netcdf.getVar(ncid,varid);
    AttS=[];
    for jatt=0:(natts-1);
        [attname] = netcdf.inqAttName(ncid,varid,jatt);
        attrvalue = netcdf.getAtt(ncid,varid,attname);
        AttS(jatt+1).attname=attname;
        AttS(jatt+1).attrvalue=attrvalue;
    end
    S.Attributes=AttS;
    Svector(c)=S;
end
%varargout{1}=Svector;
netcdf.close(ncid);