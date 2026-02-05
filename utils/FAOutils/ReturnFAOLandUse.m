function [FAOLandUse,verstring]=ReturnFAOLandUse;
% return FAO Land Use data

persistent a

if isempty(a)

    DPD=DataProductsDir;
    
    a=readgenericcsv([DPD '/ext/FAOStat/LandUse/Feb3_2026/Inputs_LandUse_E_All_Data_(Normalized)/Inputs_LandUse_E_All_Data_Normalizednq.txt'],1,tab,1);
end

verstring='Feb_2026';

FAOLandUse=a;
