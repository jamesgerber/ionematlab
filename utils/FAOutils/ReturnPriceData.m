function [PD,verstring]=ReturnPriceData;
% ReturnPriceData - read in FAOstat price data, keep persistent

persistent a

if isempty(a)
    DPD=DataProductsDir;
    thissetdir= 'ext/FAOstat/Prices/Jan2024/Prices_E_All_Data_(Normalized)/';
    a=readgenericcsv([ DPD thissetdir 'Prices_E_All_Data_Normalizednq.txt'],1,tab,1);


    a=rmfield(a,'Year_Code');
    a=rmfield(a,'Flag');
end
verstring='Jan_2024';

PD=a;
