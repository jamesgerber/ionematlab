function Outline=continentoutline(ContinentList)
%  continentoutline - return outline of continents
%
%  SYNTAX
%     Outline=continentoutline(ContinentName)
%
%   
%    where ContinentName can be one of the names below.
%   EXAMPLES
%  Outline=continentoutline({'Africa'});
%  Outline=...
%  continentoutline({'Western Europe','Northern Europe','Southern Europe'});
%
%
%     'Africa'
%    'Americas'
%    'Antartica'
%    'Asia'
%    'Europe'
%    'Oceania'
%
%    'Antartica'
%    'Australia and New Zealand'
%    'Caribbean'
%    'Central America'
%    'Central Asia'
%    'Eastern Africa'
%    'Eastern Asia'
%    'Eastern Europe'
%    'Melanesia'
%    'Micronesia'
%    'Middle Africa'
%    'Northern Africa'
%    'Northern America'
%    'Northern Europe'
%    'Polynesia'
%    'South America'
%    'South-Eastern Asia'
%    'Southern Africa'
%    'Southern Asia'
%    'Southern Europe'
%    'Western Africa'
%    'Western Asia'
%    'Western Europe'

if nargin==0
        help(mfilename)
        return
end
if ischar(ContinentList)
    ContinentList={ContinentList};
end
if length(ContinentList)==1
    ContinentName=ContinentList;
    if iscell(ContinentName)
        ContinentName=ContinentName{1};
    end
else
    ii=datablank;
    TempOutline=continentoutline(ContinentList(1));
    Outline=TempOutline | continentoutline(ContinentList(2:end));
    return
end


load([iddstring '/misc/continentoutlineData.mat'])

ii=strmatch(ContinentName,UNREGION2,'exact');

if isempty(ii)   
    ii=strmatch(ContinentName,UNREGION1,'exact');
    if isempty(ii)       
        disp(['try '])
        unique(UNREGION2),unique(UNREGION1)
        error(['Don''t know ' ContinentName ])
    end
end

Outline=datablank;

for j=1:length(ii)
    
    FAO=NAME_FAO(ii(j));
    if isempty(FAO{1})
        disp(['ignoring ' NAME_ISO(ii(j))]);
    else
        S3=standardcountrynames(FAO,'NAME_FAO','sage3');
        if isempty(S3{1})
            disp(['ignoring ' FAO])
        else
            Outline=Outline | countrycodetooutline(S3{1});
        end
    end
end

return


%% here is code used to generate continentoutlineData
load gadm1_lev0
for j=1:248;
    UNREGION1{j}=S(j).UNREGION1;
    UNREGION2{j}=S(j).UNREGION2;
    NAME_ISO{j}=S(j).NAME_ISO;
    NAME_FAO{j}=S(j).NAME_FAO;
    WBREGION{j}=S(j).WBREGION;
end

save continentoutlineData NAME_FAO NAME_ISO UNREGION1 UNREGION2

%% here is some code from Nathan to modify the outputs 
% construct regional outline maps

 

outline_oceaniaseasia = continentoutline({'Polynesia', ...
    'Australia and New Zealand','Melanesia','Micronesia','South-Eastern Asia'});

outline_latinamericacarib = continentoutline({'South America','Caribbean', ...
    'Central America'});

outline_UScanada = continentoutline({'Northern America'});
outline_southasia = continentoutline({'Southern Asia'});

outline_mideastnorthafrica = continentoutline({'Northern Africa', ...
    'Western Asia'});% note: includes Turkey and Sudan

outline_ssafrica = continentoutline({'Southern Africa', ...
    'Western Africa','Middle Africa','Eastern Africa'});

outline_westerneurope = continentoutline({'Western Europe', ...
    'Northern Europe','Southern Europe'});

outline_easterneuropeFSU = continentoutline({'Eastern Europe',...
    'Central Asia'});

outline_eastasia = continentoutline({'Eastern Asia'})
 

% make some modifications:

% transfer Sudan to Sub-Saharan Africa

outline = countrycodetooutline('SDN');
outline_mideastnorthafrica(outline == 1) = 0;
outline_ssafrica(outline == 1) = 1;
% transfer Estonia, Latvia, and Lithuania to Eastern Europe from Western

% Europe
outline = countrycodetooutline({'LTU','EST','LVA'});
outline_westerneurope(outline == 1) = 0;
outline_easterneuropeFSU(outline == 1) = 1; 