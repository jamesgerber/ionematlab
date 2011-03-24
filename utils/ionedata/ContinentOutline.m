function outline=ContinentOutline(ContinentName)
%     ''    'Africa'    'Americas'    'Antartica'    'Asia'
%     'Europe'    'Oceania'

%ContinentName='Oceania';

load([iddstring '/misc/ContinentOutlineData.mat'])


ii=strmatch(ContinentName,UNREGION2,'exact');

if isempty(ii)
  disp(['Don''t know ' Continent ])
  disp(['try '])
  unique(UNREGION2);
end

Outline=DataBlank;

for j=1:length(ii)
  j
  FAO=NAME_FAO(ii(j));
  S3=standardcountrynames(FAO,'NAME_FAO','sage3');
  Outline=Outline | CountryCodetoOutline(S3);
end




return


load gadm1_lev0
for j=1:248;
  UNREGION1{j}=S(j).UNREGION1;
  UNREGION2{j}=S(j).UNREGION2;
  NAME_ISO{j}=S(j).NAME_ISO;
  NAME_FAO{j}=S(j).NAME_FAO;
end

