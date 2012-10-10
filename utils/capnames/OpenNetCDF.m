function varargout=OpenNetCDF(varargin);
disp(['calling opennetcdf (no caps)']);
[varargout{1:nargout}]=opennetcdf(varargin{:});


%if (nargout) [varargout{1:nargout}]=feval(lower(mfilename),varargin{:});