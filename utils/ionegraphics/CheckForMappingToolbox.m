function  CanMap=CheckForMappingToolbox;
% CHECKFORMAPPINGTOOLBOX - check to see if mapping toolbox is available
S=license('inuse','map_toolbox');

try
  if isequal(S.feature,'map_toolbox')
    CanMap=1;
  else
    CanMap=0;
  end
catch
  warning(['problem in ' mfilename ])
  CanMap=0;
end

CanMap=0;