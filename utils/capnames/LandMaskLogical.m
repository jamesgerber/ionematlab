function LogicalVector=LandMaskLogical(varargin);
% LANDMASKLOGICAL -  logical array of standard landmask
%
disp(['warning ... called ' mfilename ' with capital letters.']);
LogicalVector=landmasklogical(varargin{1:end});