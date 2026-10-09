function [POPdata,years,version]=ReturnWorldBankPopulationTimeSeries(ISO3,populationyears);


persistent a
if isempty(a)
    DPD=DataProductsDir;
    a=readgenericcsv([DPD '/ext/WorldBankData/Population/April2026Download/API_SP.POP.TOTL_DS2_en_csv_v2_207128nq.txt'],3,tab,1)
end

version='Apr 2026 World Bank';

idx=find(strcmp(a.Country_Code,ISO3));


if nargin==2
    years=populationyears;
else
    years=1990:2024;
end

if isempty(idx)
    disp([' did not find ' ISO3 ' in WorldBank data'])
    POPdata=years*nan;
    return
end

for j=1:numel(years)
    YYYY=years(j);
    POPdata(j)=a.(['Val' int2str(YYYY)])(idx);
end


    
