function  CanMap=CheckForMappingToolbox;
% CHECKFORMAPPINGTOOLBOX - check to see if mapping toolbox is available
CanMap=0
return
%%S=license('inuse','map_toolbox');
result = license('checkout','map_toolbox');
try
%  if isequal(S.feature,'map_toolbox')
%    CanMap=1;
%  else
%    CanMap=0;
%  end

CanMap=result;

catch
  warning(['problem in ' mfilename ])
  CanMap=0;
end

