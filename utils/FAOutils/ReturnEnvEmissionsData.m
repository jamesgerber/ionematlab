function [EED,verstring]=ReturnEnvEmissionsData;
% ReturnEnvEmissionsData - read in FAOstat environmental emissions data, keep in
% persistent

persistent a

if isempty(a)
    DPD=DataProductsDir;
    thissetdir= 'ext/FAOstat/EmissionsIntensities/Dec2024/';
    a=readgenericcsv([ DPD thissetdir 'Environment_Emissions_intensities_E_All_Data_Normalizednq.txt'],1,tab,1);
    a=rmfield(a,'Year_Code');
 %   a=rmfield(a,'Note');
    a=rmfield(a,'Flag');
end
verstring='Dec_2024';

EED=a;
