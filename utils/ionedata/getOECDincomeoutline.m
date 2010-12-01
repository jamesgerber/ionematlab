function Outline=getOECDincomeoutline(incomelevel);
% getOECDincomeoutline
%
%     Outline=getOECDincomeoutline('high');
%     Outline=getOECDincomeoutline('mid');
%     Outline=getOECDincomeoutline('low');
%
path = [iddstring 'misc/wbiclass.csv'];
WBI = ReadGenericCSV(path);

WBIhtable = java.util.Properties;
for j=1:length(WBI.countrycode);
    income = WBI.class{j};
    % get rid of divisions between OECD and non-OECD high income
    % countries
    if strmatch('High',income);
        income = 'High income';
    end
    WBIhtable.put(WBI.countrycode{j},income);
end


ii1=strmatch('High income: OECD',WBI.class);
ii2=strmatch('High income: nonOECD',WBI.class);
ii3=strmatch('Upper middle income',WBI.class);
ii4=strmatch('Lower middle income',WBI.class);
ii5=strmatch('Low income',WBI.class);

switch lower(incomelevel)
    case {'high'}
        ii=unique([ii1' ii2']);
    case {'middle','mid'}
        ii=unique([ii3' ii4']);
    case {'low'}
ii=ii5';
end



Outline=(DataMaskLogical==2);  % create big logical array of zeros

ii=ii(:)';

a=StandardCountryNames(WBI.countrycode,'sage3');
for j=ii;
    if j==82
        warning('fix honduras please')
    else    
        Outline=Outline + CountryCodetoOutline(a{j});
    end
end