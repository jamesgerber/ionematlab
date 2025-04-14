function [EFC,verstring]=ReturnEFCData;
% return FoodBalanceSheet data

persistent a

if isempty(a)

    DPD=DataProductsDir;
    
    a=readgenericcsv([DPD '/ext/FAOstat/EmissionsFromCrops/Emissions_crops_E_All_Data_Normalized_DownloadApril10_2025/' ...
        'Emissions_crops_E_All_Data_Normalizednq.txt'],1,tab,1);


    tmp=a.Area_Code_M49;

    for j=1:numel(tmp);
        tmp{j}=strrep(tmp{j},'''','');
    end
    tmpnum=str2double(tmp);

    a.AreaM49Num=tmpnum;

end

verstring='April10_2025';

EFC=a;
