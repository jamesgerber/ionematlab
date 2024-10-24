function [FBS,verstring]=ReturnFBSData;
% return FoodBalanceSheet data

persistent a

if isempty(a)

    DPD=DataProductsDir;
    
    a=readgenericcsv([DPD '/ext/FAOstat/FoodBalanceSheets/July2024/FoodBalanceSheets_E_All_Data_Normalizednq.txt'],1,tab,1);
end

verstring='July_2024';

FBS=a;
