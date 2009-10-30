function AddCoastCallBack(varargin);
% AddCoastCallBack - Zoom graph to maximum value.

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
       
        uicontrol('String','Add Coastline','Callback', ...
            'AddCoastCallBack(''AddCoast'')','position',[430 10 80 20]);
        
    case 'AddCoast'
        % find maximum, zoom in       
        
        AddCoasts(gcbf);
    otherwise
        error('syntax error in AddCoastCallBack.m')
        
end
end
