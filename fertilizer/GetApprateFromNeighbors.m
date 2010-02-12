function [avgneighbor,neighbors]=GetApprateFromNeighbors(...
    countrycode,co_codes,co_outlines,co_numbers,ctries_withdata)

% function [avgneighbor,neighbors]=GetApprateFromNeighbors(...
%     countrycode,co_codes,co_outlines,co_numbers,ctries_withdata)
% 

Neighbors=GetBestNeighbors(countrycode,2,ctries_withdata); % note this
% might return data for the country you fed it ... does not yet restrict to
% good countries (ctries_withdata)

if length(Neighbors)>0
    for m = 1:length(Neighbors)
        neighborcode = Neighbors{m}
        
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
    
    if length(ratelist)>0 %%%% NOTE: this should be true b/c we should 
        % only get back ctries with data from GetBestNeighbors
        
        %%%%% THIS NEEDS MORE WORK - weight the average by the
        %%%%% border length / distance from country?
        
        avgneighbor = mean(ratelist);
        
        % list the countries
        neighborlist = [];
        for k = 1:length(Neighbors);
            tmp = Neighbors{k};
            neighborlist = [neighborlist '; ' tmp];
        end
        
        disp(['Filling in data for ' sagecountryname ' with' ...
            ' average application rate data from ' neighborlist]);
        
        ii = find(ctry_appratemap == -9);
        appratemap(ii) = avgneighbor;
        
    else
        sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')
        disp(['No neighbors with data available for ' sagecountryname]);
        
    end
    
else % this shouldn't happen
    sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')
    disp(['No neighbors available for ' sagecountryname]);
end