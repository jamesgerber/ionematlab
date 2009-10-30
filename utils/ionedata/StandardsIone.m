function StandardsIone
%StandardsIone - print notes on standards for data manipulation
%
% Standard format for calls to functions:  
%    PlanetView(long,lat,Data)
%       where
%         long   =   mx1 column vector
%         lat    =   nx1 column vector
%         Data   =   mxn double array
%    
%   Notes:  a call to surface would thus look like surface(long,lat,Data.');
%           This orientation for the Data matrix appears to be
%           consistent with storage in NetCDF files.
%
%
%   PLOTTING
%
%     I find that using  
%       set(gcf,'renderer','zbuffer') 
%   after making a plot with lots of data seems to improve the problem with
%   being unable to close the window 
%
%
%   COLORMAPS
%
%   For data which is positive, 
%            use value -1 for missing data (i.e. data which had value 1e20)
%            use value -2 for
%   data 
%
%   DATASTRUCTURES
%
%    DS.Data = Data 
%    DS.Long
%    DS.Lat
%    DS.Units
%    DS.Title
%    DS.DataSource
%    DS.MissingValue
%    DS.DataName
%    DS.IoneDataStructure='True'
%
%
if nargin==0
  help(mfilename);
end
