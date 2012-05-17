function makelandmask(LogicalMask,FileName);
% MAKELANDMASK - make a land mask and associated gridfile
%
% Syntax
%       makelandmask
%     
%       makelandmask(datamasklogical,FileName);
%
%  Example
%
%       makelandmask(datamasklogical);
%
%       makelandmask(countrynametooutline('France'))

switch nargin
 case 0
  disp(['default landmask'])
  LogicalMask=datamasklogical;
  FileName='surta.nc';
  GridFileName='gridfile';
 case 1
  FileName='surta.nc';
  GridFileName='gridfile';
 case 2
  GridFileName='gridfile';
case 3
  % nothing to do.  User passed in everything
end


% make sure that LogicalMask is in fact locigal
LogicalMask=logical(LogicalMask);

[Long,Lat]=inferlonglat(LogicalMask);

Data=single(LogicalMask);

DAS.title='Land Mask For Pegasus';
DAS.information=['Created on ' date '. 1=to analyze, 0=ignore'];
DAS.missing_value=9.e+20;
DAS.units='none';

writenetcdf(Long,Lat,Data,'surta',FileName,DAS);




%! This file specifies the subset grid over which we are running,
%! and the resolution of the model run.%
%
%! The land mask (surta.nc) must be specified at the given resolution,
%! but with global extent. Other input files can be at this resolution or
%! coarser resolution. For more details, see the note in
%! build/README-first, under the files contained in the maps directory.
%
%90     ! snorth     northern boundary of subset grid
%-90    ! ssouth     southern boundary
%-180    ! swest      western
%180    ! seast      eastern
%600    ! resolution (arc-seconds)
