function [appratemap]=GetApprateFromNeighbors(...
    countrycode,co_codes,co_outlines,co_numbers,ctries_withdata,appratemap)

% function [avgneighbor,neighbors]=GetApprateFromNeighbors(...
%     countrycode,co_codes,co_outlines,co_numbers,ctries_withdata,appratemap)
%


% get the country we're working on ...
sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')

Neighbors=GetBestNeighbors(countrycode,2,ctries_withdata); % note this
% might return data for the country you fed it ... does not yet restrict to
% good countries (ctries_withdata)

ratelist = [];

if length(Neighbors)>0
    for m = 1:length(Neighbors)
        neighborcode = Neighbors{m}
        
        % now check to make sure this is in ctries_withdata ... this will
        % return the position in the ctries_withdata list of the neighbor
        tmp = strmatch(neighborcode, ctries_withdata);
        if length(tmp)>0
            
            ii = strmatch(neighborcode, co_codes);
            tmp = co_numbers(ii);
            ii = find(co_outlines == tmp);
            outline = zeros(4320,2160);
            outline(ii) = 1;
            
            ctry_appratemap = appratemap .* outline;
            ii = find(isfinite(ctry_appratemap));
            tmp = ctry_appratemap(ii);
            
            ii = find(tmp == -9);
            tmp(ii) = [];
            ii = find(tmp == 0);
            tmp(ii) = [];
            
            ratelist = [ratelist tmp];
            
        end
    end
    if length(ratelist)>0
        
        %%%%% THIS NEEDS MORE WORK - weight the average by the
        %%%%% border length / distance from country?
        
        % also weight by area
        
        avgneighbor = mean(ratelist);
        
        % list the countries
        neighborlist = [];
        for k = 1:length(Neighbors);
            tmp = Neighbors{k};
            neighborlist = [neighborlist '; ' tmp];
        end
        
        disp(['Filling in data for ' sagecountryname ' with' ...
            ' average application rate data from ' neighborlist]);
        
        ii = strmatch(countrycode, co_codes);
        tmp = co_numbers(ii);
        ii = find(co_outlines == tmp);
        outline = zeros(4320,2160);
        outline(ii) = 1;
        ctry_appratemap = appratemap .* outline;
        ii = find(ctry_appratemap == -9);
        appratemap(ii) = avgneighbor;
        
    else
        sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')
        disp(['WARNING: No neighbors with data available for ' sagecountryname ...
            '; filling in application rate data with zeros']);
        
        ii = strmatch(countrycode, co_codes);
        tmp = co_numbers(ii);
        ii = find(co_outlines == tmp);
        outline = zeros(4320,2160);
        outline(ii) = 1;
        ctry_appratemap = appratemap .* outline;
        ii = find(ctry_appratemap == -9);
        appratemap(ii) = 0;
        
    end
    
    
else % this shouldn't happen
    
    disp(['WARNING: No neighbors available for ' sagecountryname ...
        '; filling in application rate data with zeros']);
    ii = strmatch(countrycode, co_codes);
        tmp = co_numbers(ii);
        ii = find(co_outlines == tmp);
        outline = zeros(4320,2160);
        outline(ii) = 1;
        ctry_appratemap = appratemap .* outline;
    ii = find(ctry_appratemap == -9);
    appratemap(ii) = 0;
end