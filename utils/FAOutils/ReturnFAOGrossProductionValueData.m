function [CPD,verstring,CPDfull]=ReturnFAOGrossProductionValueData;
% ReturnFAOGrossProductionValueData - FAO Production Value (not Price)
%
%  [CPD,verstring]=ReturnFAOGrossProductionValueData;
%
% code relies on some reformatting of the raw .csv file - codes to do that
% stored with the file

persistent a

if isempty(a)
%     tmp=which(mfilename)
%     [FilePath,NAME,EXT] = fileparts(tmp);
%     wd=pwd
%     cd(FilePath)
%     CPD=ReadProductionData;
%     a=CPD;
%     cd(wd)

%     wd=pwd
%     cd ~/DataProducts/ext/FAOstat/Production/
%     CPD=ReadProductionData;
%     a=CPD;
%     cd(wd)
% verstring='March18_2021_RevE';
DPD=DataProductsDir;

a=readgenericcsv([DPD '/ext/FAOstat/ValueOfProduction/Latest/Value_of_Production_E_All_Data_Normalizednq.txt'],1,tab,1);

end

verstring='Mar2024';


CPDfull=a;
ii=strmatch('Crops',a.Item);
CPD=subsetofstructureofvectors(a,ii);


