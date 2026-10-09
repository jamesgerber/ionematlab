function [GDPdata,years,version]=ReturnWorldBankGDPTimeSeries(ISO3,gdpyears);
% ReturnWorldBankGDPTimeSeries(ISO3,gdpyears);
% 

if nargin==0
    help(mfilename)
    return
end

persistent a
if isempty(a)
    %a=readgenericcsv('/Users/jsgerber/DataProducts/ext/WorldBankData/GDP/GDPTransposed.txt',2,tab,1);
    a=readgenericcsv('/Users/jsgerber/DataProducts/ext/WorldBankData/GDP/Mar2026Download/API_NY.GDP.MKTP.PP.KD_DS2_en_csv_v2_1004nq.txt',5,tab,1)

x=fieldnames(a);


for j=5:numel(x);
    fn=x{j};
    if iscell(a.(fn))
        a.(fn)=a.Val1990*nan;
    end
end
end

version='Mar 2026 World Bank';

idx=find(strcmp(a.Country_Code,ISO3));


if nargin==2
    years=gdpyears;
else
    years=1990:2024;
end

if isempty(idx)
    disp([' did not find ' ISO3 ' in WorldBank data'])
    GDPdata=years*nan;
    return
end

for j=1:numel(years)
    YYYY=years(j);
    GDPdata(j)=a.(['Val' int2str(YYYY)])(idx);
end


    
