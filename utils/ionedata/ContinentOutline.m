function Outline=ContinentOutline(ContinentList)
%  ContinentOutline - return outline of continents
%
%  SYNTAX
%     Outline=ContinentOutline(ContinentName)
%
%
%    where ContinentName can be one of the names below.
%
%  Outline=...
%  ContinentOutline({'Western Europe','Northern Europe','Southern Europe'});
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

if length(ContinentList)==1
    ContinentName=ContinentList;
    if iscell(ContinentName)
        ContinentName=ContinentName{1};
    end
else
    ii=DataBlank;
    TempOutline=ContinentOutline(ContinentList(1));
    Outline=TempOutline | ContinentOutline(ContinentList(2:end));
    return
end


load([iddstring '/misc/ContinentOutlineData.mat'])

ii=strmatch(ContinentName,UNREGION2,'exact');

if isempty(ii)   
    ii=strmatch(ContinentName,UNREGION1,'exact');
    if isempty(ii)       
        disp(['try '])
        unique(UNREGION2),unique(UNREGION1)
        error(['Don''t know ' ContinentName ])
    end
end

Outline=DataBlank;

for j=1:length(ii)
    
    FAO=NAME_FAO(ii(j));
    if isempty(FAO{1})
        disp(['ignoring ' NAME_ISO(ii(j))]);
    else
        S3=standardcountrynames(FAO,'NAME_FAO','sage3');
        Outline=Outline | CountryCodetoOutline(S3{1});
    end
end

return


%% here is code used to generate ContinentOutlineData
load gadm1_lev0
for j=1:248;
    UNREGION1{j}=S(j).UNREGION1;
    UNREGION2{j}=S(j).UNREGION2;
    NAME_ISO{j}=S(j).NAME_ISO;
    NAME_FAO{j}=S(j).NAME_FAO;
    WBREGION{j}=S(j).WBREGION;
end

save ContinentOutlineData NAME_FAO NAME_ISO UNREGION1 UNREGION2