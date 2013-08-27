function varargout= mdnplot(varargin);


switch nargout
    case 0
        
        plot(varargin{1:end});
        
    otherwise
        varargout{1:nargout}=plot(varargin{1:end});
end


uicontrol('String','refreshdate','Callback', ...
            'datetick(''keeplimits'')','position',[5.0000   12.5000  120.0000   25.0000]);
zoom on