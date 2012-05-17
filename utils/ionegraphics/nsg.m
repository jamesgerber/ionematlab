function OS=nsg(varargin);
% NICESURFGENERAL / nsg
%
%  calls nicesurfGeneral
%
%  See also nicesurfGeneral

if nargin==0
    help('nicesurfGeneral')
    return
end

OS=nicesurfGeneral(varargin{1:end});


