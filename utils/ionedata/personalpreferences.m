function x=personalpreferences(variable,setting)
% PERSONALPREFERENCES - get or set personal default settings for
% NiceSurfGeneral and finemap, oceancolor, nodatacolor, latlongcolor, and
% printingres
%
%  Syntax
%
%      x=personalpreferences(variable) - returns the current setting for
%      variable, or '' if none.
%
%      x=personalpreferences(variable,setting) - sets variable to setting,
%      returns previous setting
%
oceancolor='';
nodatacolor='';
latlongcolor='';
printingres='';
load personalprefsactual
try
    eval(['x=' variable ';']);
catch
    x='';
end
if (nargin>1)
    eval([variable '=setting;']);
end
save('personalprefsactual','oceancolor','nodatacolor','latlongcolor','printingres');