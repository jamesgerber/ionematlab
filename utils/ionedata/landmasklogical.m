function LogicalVector=landmasklogical(DataTemplate);
% LANDMASKLOGICAL -  logical array of standard landmask
%
%  Syntax
%
%      LogicalMatrix=landmasklogical - returns the 5 minute landmask
%
%      LogicalMatrix=landmasklogical(DataTemplate) -returns a landmask of
%        the size of DataTemplate (if DataTemplate is 5 or 10 mins)

persistent LogicalLandMaskVector

if isempty(LogicalLandMaskVector)
    systemglobals
    [Long,Lat,Data]=opennetcdf(LANDMASK_5MIN);
    LogicalLandMaskVector=(Data>0);
end

LogicalVector=LogicalLandMaskVector;

if nargin==0
    return
end

% if we are here, it is because a DataTemplate was passed in.

switch numel(DataTemplate)
    case 4320*2160  %5min
        return
    case 2160*1080  %10min
        
        ii=1:2:4319;
        jj=1:2:2159;
        
        LogicalVector10min=...
            (LogicalVector(ii,jj)  | ...
            LogicalVector(ii,jj+1) | ...
            LogicalVector(ii+1,jj) | ...
            LogicalVector(ii+1,jj+1));
        
        LogicalVector=LogicalVector10min;
    case 720*360  %30min / .5 degree
        systemglobals
        try
            [Long,Lat,Data]=aopennetcdf(LANDMASK_30MIN);
        catch
            warning([' didn''t find LANDMASK_30MIN.  downsampling 5min landmask. '])
            lml=landmasklogical;
            Data=lml(1:6:end,1:6:end);
        end
        LogicalVector=(Data>0);
    case 144*72 %2.5 degrees

        lml=landmasklogical;
        Data=aggregate_rate(lml,30);     
        LogicalVector=(Data>=0.5);
        
    otherwise
        error(['don''t have a landmask at this size'])
end



