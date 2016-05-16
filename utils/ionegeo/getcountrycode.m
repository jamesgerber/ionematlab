function ccstructure=getcountrycode(countryname);
% getcountrycode - turn a country name into structure of country codes
%
% Syntax CCstructure=getcountrycode('latvia')
%
% this code should not be used within functions - I doubt that this will be
% robust.

% strip out anything in parenthesis
ii=findstr(countryname,'(');

if numel(ii)>0
    disp(['searching "' deblank(countryname(1:ii-1)) '"' ...
       ' instead of "'  countryname '"']);
       
       countryname=deblank(countryname(1:ii-1));
end



[s,w]=unix(['grep -i "' countryname '" /psldata/humangeography/admincodes/countrycodes_RevD.txt']);
    
if s~= 0    

        [s,w]=unix(['grep -i "' countryname '" ' iddstring 'misc/countrycodes_RevD.txt']);

end


if s~=0
    
    if isequal(countryname,'Korea, Democratic People''s Republic of');
        ccstructure=StandardCountryNames('PRK','ISO3');
        return
    end
    if ~isempty( findstr(countryname,'Ivoire') )
        warndlg([' interpreting ' countryname ' as cote d''ivoire']);
        ccstructure=StandardCountryNames('CIV','ISO3');
        return
    end
    
    if ~isempty( findstr(countryname,'Congo') )
        warndlg([' interpreting ' countryname ' as Democratic Rep Congo']);
        ccstructure=StandardCountryNames('COD','ISO3');
        return
    end
        
       if ~isempty( findstr(countryname,'Iran') )
        warndlg([' interpreting ' countryname ' as Democratic Rep Congo']);
        ccstructure=StandardCountryNames('IRN','ISO3');
        return
    end
    if ~isempty( findstr(countryname,'Venezuela') )
        warndlg([' interpreting ' countryname ' as Venezuela']);
        ccstructure=StandardCountryNames('VEN','ISO3');
        return
    end
      if ~isempty( findstr(countryname,'China, mainland') )
        warndlg([' interpreting ' countryname ' as China']);
        ccstructure=StandardCountryNames('CHN','ISO3');
        return
    end

        
        error([' call to grep did not work for ' countryname]);
end

if length(findstr(w,tab)) > 20
    switch countryname
        case 'Dominica'
            ccstructure=StandardCountryNames('MDA','ISO3');
     %   case 'Dominican Republic'
     %       ccstructure=StandardCountryNames('DOM');
     
        case {'Republic of Korea','Korea'}
            ccstructure=StandardCountryNames('KOR','ISO3');

        case 'India'
            ccstructure=StandardCountryNames('IND','ISO3');

            
   %     case 'Germany'
   %         ccstructure=StandardCountryNames('DEU');

        case {'China','China, mainland'}
            ccstructure=StandardCountryNames('CHN','ISO3');
        case 'Republic of Congo'
            %warndlg(['Unable to interpret Congo, please clarify which country.'])
            ccstructure=StandardCountryNames('COG','ISO3');
        case 'Democratic Republic of the Congo'
            ccstructure=StandardCountryNames('COD','ISO3');
            
        case 'Niger'
            display(['Interpreting as Niger, not Nigeria'])
            ccstructure=StandardCountryNames(['Niger']);
        case 'Nigeria'
            display(['Interpreting as Nigeria, not Niger'])
            ccstructure=StandardCountryNames(['NGA','ISO3']);
        case 'Georgia'
            display(['Interpreting as Georgia not South Georgia'])
            ccstructure=StandardCountryNames(['Georgia']);
        case 'Guinea'
            display(['Interpreting as Guinea'])
            ccstructure=StandardCountryNames('GIN','ISO3');
        case 'Luxembourg'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('LUX','ISO3');
        case 'Mali'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('MLI','ISO3');
        case 'Montenegro'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('MNE','ISO3');
        case 'Netherlands'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('NLD','ISO3');
        case 'Oman'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('OMN','ISO3');
        case 'Samoa'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('WSM','ISO3');
        case 'Serbia'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('SRB','ISO3');
        case 'Sudan'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('SDN','ISO3');
        case 'United States'
            %display(['Interpreting as Luxembourg'])
            ccstructure=StandardCountryNames('USA','ISO3');
        otherwise
    error([' found multiple matches.  boo! ']);
    end
    return
end

ccstructure=StandardCountryNames(w(1:3),'ISO3');

