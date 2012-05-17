function Outline=getoecdincomeoutline(incomelevel);
% getoecdincomeoutline - get outlines of OECD income levels
%
%   Syntax
%     Outline=getoecdincomeoutline('high');  
%
%  These are the levels
%   'High income: OECD'
%   'High income: nonOECD';
%   'Upper middle income'
%   'Lower middle income'
%   'Low income'
%
%     Outline=getoecdincomeoutline('high');  gives combination of first two
%     Outline=getoecdincomeoutline('mid');   gives Upper and Lower middle 
%     Outline=getoecdincomeoutline('low');   gives "Low income"
%
%     Outline=getoecdincomeoutline('ii1'); just 'High income: OECD'
%     Outline=getoecdincomeoutline('ii2'); just 'High income: nonOECD'
%     Outline=getoecdincomeoutline('um'); just 'Upper middle income'
%     Outline=getoecdincomeoutline('lm'); just 'Lower middle income'
%     Outline=getoecdincomeoutline('low');   just "Low income"



%  
path = [iddstring 'misc/wbiclass.csv'];
WBI = readgenericcsv(path);

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
    case {'low','lo'}
        ii=ii5';
    case {'upper middle','um'}
        ii=ii3';
    case {'lm','lower middle'}
        ii=ii4'; 
    case {'high_non','ii2'}
        ii=ii2';
    case {'ii1','hioecd'}
        ii=ii1';
end



Outline=(datamasklogical==2);  % create big logical array of zeros

ii=ii(:)';

a=standardcountrynames(WBI.countrycode,'sage3');
for j=ii;
 %   if j==82
 %       warning('fix honduras please')
 %   else    
        Outline=Outline + countrycodetooutline(a{j});
 %   end
end

Outline=logical(Outline);