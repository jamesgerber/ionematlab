function [appratemap]=GetApprateFromSimilar(countrycode, ...
    ctries_withdata, appratemap, areahamap, globalavg)

% function [appratemap]=GetApprateFromSimilar(countrycode, ...
%     ctries_withdata, appratemap, areahamap, globalavg)
% 
% 
% 
% 


SystemGlobals;




















persistent WBIhtable


if isempty(WBIhtable)
    
    path = [IoneDataDir 'misc/WBIinfo.mat'];
    eval(['load ' path ';']);
    
    WBIhtable = java.util.Properties;
    for j=1:length(WBI_Clist);
        income = WBI_Ilist{j};
        % get rid of divisions between OECD and non-OECD high income
        % countries
        if strmatch('High',income);
            income = 'High income';
        end    
        WBIhtable.put(WBI_Clist{j},income);
    end
end

% get the income level for this country

incomelevel = WBIhtable.get(countrycode);

ratelist = [];
arealist = [];
similar = {};

for c = 1:length(ctries_withdata)
    datactry = ctries_withdata{c};
    tmp = WBIhtable.get(datactry);
% %     ii = strmatch(datactry,WBI_Clist);
% %     tmp = WBI_Ilist(ii);
    
    % if the income levels match, add to ratelist (and similar list)

    if strmatch(incomelevel,tmp);
        
        similar{end+1} = datactry;
        
        outline = CountryCodetoOutline(datactry);
        
        ctry_appratemap = appratemap .* outline;
        ii = find(isfinite(ctry_appratemap));
        
        tmp = ctry_appratemap(ii);
        tmp2 = areahamap(ii);
        
        ii = find(tmp == -9);
        tmp(ii) = [];
        tmp2(ii) = [];
        ii = find(tmp == 0);
        tmp(ii) = [];
        tmp2(ii) = [];
        
        ratelist = [ratelist(:)' tmp(:)'];
        arealist = [arealist(:)' tmp2(:)'];
        
    end
end

if length(ratelist)>0
    
    % create an area-weighted average application rate using the rates from
    % countries of similar economic status
    
    tmp = ratelist(:) .* arealist(:);
    tmp = mean(tmp);
    meanarea = mean(arealist);
    simctryrate = tmp ./ meanarea;
    
    % list the countries
    similarlist = [];
    for k = 1:length(similar);
        tmp = similar{k};
        similarlist = [similarlist '; ' tmp];
    end
    
    disp(['Filling in data for ' countrycode ' with' ...
        ' average application rate data from ' incomelevel ...
        ' countries: ' similarlist]);
    
    outline = CountryCodetoOutline(countrycode);
    ctry_appratemap = appratemap .* outline;
    ii = find(ctry_appratemap == -9);
    appratemap(ii) = simctryrate;
    
else
    
    disp(['WARNING: No similar countries for ' countrycode ...
        '; using global average data']);
    outline = CountryCodetoOutline(countrycode);
    ctry_appratemap = appratemap .* outline;
    ii = find(ctry_appratemap == -9);
    appratemap(ii) = globalavg;
    
end