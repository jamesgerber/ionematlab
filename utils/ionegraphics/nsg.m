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

if nargin==1
    % only syntax that can lead to this is calling with a single variable
    NSS.titlestring=inputname(1)
    OS=NiceSurfGeneral(varargin{1:end},NSS);
    showui
else
    OS=NiceSurfGeneral(varargin{1:end});
end

