function varargout=getcropdata(DataString,Year);
% GETCROPDATA - Get IONE crop data
%
%  Syntax
%
%   [S]=getdata(DataString)
%
%   [S]=getdata(DataString,Year)
%
%   Default value for Year is 2000
%
%  Example
%
%    [Long,Lat,maize2000]=getcropdata('maize',2000);
%
%  if DataString is a crop, and there are three output arguments
%   [CropStruct,area,yield]=getdata('croparea');
%
%  See Also getdata

if nargin==0 | nargout==0
    help(mfilename)
    return
end

if nargin<2
    Year=2000;
end

switch Year
    case 2000
        try
            S=OpenNetCDF([iddstring '/Crops2000/crops/' DataString '_5min.nc']);
            iscrop=1;
        catch
            error([' can''t find ' DataString ' for Year ' int2str(Year)]);
        end
        
    case 2005
        try
            S=OpenNetCDF([iddstring '/Crops'  int2str(Year)  '/crops/' ...
                DataString '_' int2str(Year) '_5min.nc']);
            iscrop=1;
        catch
            error([' can''t find ' DataString ' for Year ' int2str(Year)]);
        end
        
    otherwise
        error([' Don''t have anything yet for year ' int2str(Year) ]);
        
        
end


switch nargout
    case 1
        varargout{1}=S;
    case 3

            varargout{1}=S;
            ii=GoodDataIndices(S);
            tmp=S.Data(:,:,1);
            tmp(~ii)=NaN;
            varargout{2}=tmp;
            tmp=S.Data(:,:,2);
            tmp(~ii)=NaN;
            varargout{3}=tmp;
        
end
