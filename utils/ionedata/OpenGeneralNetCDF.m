function Svector=OpenGeneralNetCDF(varargin)
persistent madewarning

if isempty(madewarning)
    disp(['calling version with (no caps)']);
    madewarning=1;
end

Svector=opengeneralnetcdf(varargin{:});
