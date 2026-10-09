function [FBS,verstring]=ReturnFBSEmissions;
% return ReturnFBSEmissions data

persistent a

if isempty(a)

    DPD=DataProductsDir;
    
    a=readgenericcsv([DPD '/ext/FAOstat/' ...
        'Emissions/Emissions_Totals_E_All_Data_Oct28_2025/' ...
        '        FoodBalanceSheets/July2024/FoodBalanceSheets_E_All_Data_Normalizednq.txt'],1,tab,1);
end

verstring='July_2024';

FBS=a;
