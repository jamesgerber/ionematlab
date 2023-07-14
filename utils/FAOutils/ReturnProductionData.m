function [CPD,verstring]=ReturnProductionData;


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

    x=load('~/DataProducts/ext/FAOstat/Production_Crops_Livestock_E_All_Data_(Normalized)/justcropproductiondata.mat');
    a=x.c;
    
end

verstring='March_2023';

CPD=a;
