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
        case 'Congo'
            warndlg([' found ''congo'' in getcountrycode.  interpreting as congo not DRC'])
            ccstructure=StandardCountryNames('COG','ISO3');
        otherwise
    error([' found multiple matches.  boo! ']);
    end
    return
end

ccstructure=StandardCountryNames(w(1:3),'ISO3');

