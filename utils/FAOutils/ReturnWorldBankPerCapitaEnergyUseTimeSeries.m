function [pcEnergyUsedata,years,version]=ReturnWorldBankPerCapitaEnergyUseTimeSeries(ISO3,gdpyears);


persistent a
if isempty(a)
    DPD=DataProductsDir;
    a=readgenericcsv([DPD '/ext/WorldBankData/PerCapitaEnergyUse/April2026/API_EG.USE.PCAP.KG.OE_DS2_en_csv_v2_4893nq.txt'],5,tab,1)
end

version='Apr 2026 World Bank';

idx=find(strcmp(a.Country_Code,ISO3));


if nargin==2
    years=gdpyears;
else
    years=1990:2024;
end

if isempty(idx)
    disp([' did not find ' ISO3 ' in WorldBank data'])
    pcEnergyUsedata=years*nan;
    return
end

for j=1:numel(years)
    YYYY=years(j);
    pcEnergyUsedata(j)=a.(['Val' int2str(YYYY)])(idx);
end

pcEnergyUsedata=str2double(pcEnergyUsedata);
    
