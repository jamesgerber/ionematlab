function ccstructure=getcountrycode(countryname);
% getcountrycode - turn a country name into structure of country codes
%
% Syntax CCstructure=getcountrycode('latvia')
%
% this code should not be used within functions - I doubt that this will be
% robust.

[s,w]=unix(['grep -i "' countryname '" /psldata/humangeography/admincodes/countrycodes_RevB.txt']);

if s~=0
    if ~isempty( findstr(countryname,'Ivoire') )
        warndlg([' interpreting ' countryname ' as cote d''ivoire']);
        ccstructure='CIV';
        return
    else
        error([' call to grep did not work ']);
    end
end

if length(findstr(w,tab)) > 20
    switch countryname
        case 'Dominica'
            ccstructure='MDA';
        case 'Dominican Republic'
            ccstructure='MDA';

        case 'China'
            ccstructure='CHN';
        case 'Congo'
            warndlg([' found ''congo'' in getcountrycode.  interpreting as congo not DRC'])
            ccstructure='COG';
        otherwise
    error([' found multiple matches.  boo! ']);
    end
end

ccstructure=StandardCountryNames(w(1:3),'ISO3');

