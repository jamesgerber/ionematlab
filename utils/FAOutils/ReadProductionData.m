function a=ReadProductionData
% 
% firsttime=0
% if firsttime==1
%     wd=pwd
%     cd March18_2021_RevE/Production_Crops_Livestock_E_All_Data_Normalized
% 
%     csv2tabdelimited Production_Crops_Livestock_E_All_Data_Normalized.csv
%     !LC_CTYPE=C sed  's/"//g' Production_Crops_Livestock_E_All_Data_Normalized.txt > Production_Crops_Livestock_E_All_Data_Normalizednq.txt
% cd(wd)
% end
 wd=pwd
 cd(DataProductsDir)
 cd ext/FAOstat/Production_Crops_Livestock_E_All_Data_(Normalized)/Oct2024
%cd March18_2021_RevE/Production_Crops_Livestock_E_All_Data_Normalized


a=readgenericcsv('Production_Crops_Livestock_E_All_Data_Normalizednq.txt',1,tab,1);
cd(wd)
