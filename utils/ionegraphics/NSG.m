function OS=NSG(varargin);
% NICESURFGENERAL / NSG
%
%  calls NiceSurfGeneral
%
%  See also NiceSurfGeneral

if nargin==0
    help('NiceSurfGeneral')
    return
end

OS=NiceSurfGeneral(varargin{1:end});


