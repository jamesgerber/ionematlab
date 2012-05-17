function addstatesCallBack(varargin);

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
       
        uicontrol('String','Add States','Callback', ...
            'addstatesCallBack(''AddCoast'')','position',nextbuttoncoords);
        
    case 'AddCoast'
        % find maximum, zoom in       
        
        addstates(gcbf);
    otherwise
        error('syntax error in addstatesCallBack.m')
        
end
end
