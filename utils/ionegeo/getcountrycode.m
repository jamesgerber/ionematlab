function ccstructure=getcountrycode(countryname);
% getcountrycode - turn a country name into structure of country codes
%
% Syntax CCstructure=getcountrycode('latvia')
%
% this code should not be used within functions - I doubt that this will be
% robust.

[s,w]=unix(['grep -i ' countryname ' /psldata/humangeography/admincodes/countrycodes_RevB.txt']);

if s~=0
    error([' call to grep did not work ']);
end

if length(findstr(w,tab)) > 20
    w
    error([' found multiple matches.  boo! ']);
end

ccstructure=StandardCountryNames(w(1:3),'ISO3');

