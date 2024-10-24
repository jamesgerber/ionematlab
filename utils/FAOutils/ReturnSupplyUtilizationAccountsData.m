function [SUA,verstring]=ReturnSupplyUtilizationAccountsData;
% return FoodBalanceSheet data

persistent a

if isempty(a)

    DPD=DataProductsDir;
    
    a=readgenericcsv([DPD '/ext/FAOstat/SupplyUtilization/Oct5_2024/SUA_Crops_Livestock_E_All_Data_Normalized/SUA_Crops_Livestock_E_All_Data_Normalizednq.txt'],1,tab,1);
end

verstring='Oct5_2024';

SUA=a;
