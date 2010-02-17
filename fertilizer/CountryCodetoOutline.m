function [outline] = CountryCodetoOutline(countrycode)

% CountryCodetoOutline.m
% 
% Syntax: [outline] = CountryCodetoOutline(countrycode)
%    where countrycode is a SAGE 3-letter country code
%
% Returns a logical 5 min x 5 min array with 1s for the country of
% interest.


persistent co_htable

if isempty(co_htable)
    
    workingdir = pwd;
    SystemGlobals
    str = ([IoneDataDir 'misc']);
    cd(str);
    load 5mincountries;
    cd(workingdir);
    
    co_htable = java.util.Properties;
    for j=1:length(co_codes);
        code = co_codes{j};
        tmp = co_numbers(j);
        ii = find(co_outlines == tmp);
        co_htable.put(co_codes{j},ii);
    end
end

outline = zeros(4320,2160);
ii = co_htable.get(countrycode);
outline(ii) = 1;