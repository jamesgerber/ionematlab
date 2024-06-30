function [GDPdata,years]=ReturnWorldBankGDPTimeSeries(ISO3,gdpyears);


persistent a
if isempty(a)
    a=readgenericcsv('/Users/jsgerber/DataProducts/ext/WorldBankData/GDP/GDPTransposed.txt',2,tab,1);
end


years=str2double(a.Country_Code(4:end));

GDPdata=str2double(a.(ISO3)(4:end));


if nargin==2

    ii=ismember(years,gdpyears);

    years=years(ii);
    GDPdata=GDPdata(ii);
end


    
