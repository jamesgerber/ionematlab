function [ISO3,UN_Name]=GetISO3Code(code,codeID,countrycodes);
% GetISO3Code - turn user-supplied code, codeID into ISO3 code


switch lower(codeID)
    case {'faostatcode','faostat_country_code'}
        % user means FAOstat_country_code
        
        ii=strmatch(code,countrycodes.FAOstat_country_code);
        
        ISO3=countrycodes.ISO3{ii};
        UN_Name=countrycodes.UN_Name{ii};
    otherwise
        error([' somthing wronk in ' mfilename '. codeID was ' codeID ]);
end
