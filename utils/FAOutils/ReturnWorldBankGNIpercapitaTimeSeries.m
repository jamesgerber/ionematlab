function [GNIpcdata,years,version]=ReturnWorldBankGNIpercapitaTimeSeries(ISO3,gniyears);
% ReturnWorldBankGNIpercapitaTimeSeries(ISO3,gdpyears);
%

% processing notes:
% manually removed the 2025 column (had limited data (if any)) from the .csv
% csv2tabdelimited API_NY.GNP.PCAP.PP.CD_DS2_en_csv_v2_252340.csv
% !   sed  's/"//g' API_NY.GNP.PCAP.PP.CD_DS2_en_csv_v2_252340.txt > API_NY.GNP.PCAP.PP.CD_DS2_en_csv_v2_252340nq.txt


if nargin==0
    help(mfilename)
    return
end

persistent a
if isempty(a)

    a=readgenericcsv('/Users/jsgerber/DataProducts/ext/WorldBankData/GNI/June2026Download/API_NY.GNP.PCAP.PP.CD_DS2_en_csv_v2_252340nq.txt',5,tab,1)

    x=fieldnames(a);


    for j=5:numel(x);
        fn=x{j};
        if iscell(a.(fn))
            a.(fn)=a.Val1990*nan;
        end
    end
end

version='Apr 2026 World Bank';

idx=find(strcmp(a.Country_Code,ISO3));


if nargin==2
    years=gniyears;
else
    years=1990:2024;
end

if isempty(idx)
    disp([' did not find ' ISO3 ' in WorldBank data'])
    GNIpcdata=years*nan;
    return
end

for j=1:numel(years)
    YYYY=years(j);
    GNIpcdata(j)=a.(['Val' int2str(YYYY)])(idx);
end



