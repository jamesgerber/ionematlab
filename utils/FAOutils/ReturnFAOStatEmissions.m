function [FAOStatEmissions,verstring]=ReturnFAOStatEmissions
% return ReturnFBSEmissions data

persistent a

if isempty(a)

    DPD=DataProductsDir;
    
    a=readgenericcsv([DPD '/ext/FAOstat/' ...
        'Emissions/Emissions_Totals_E_All_Data_Oct28_2025/' ...
        '/Emissions_Totals_E_All_Data_NOFLAGnq.txt'],1,tab,1);
    a=WideToLong(a);

    % let's remove future values, and anything before 1980

    ii=a.Year<=2025 & a.Year >= 1980;

    a=subsetofstructureofvectors(a,ii)
    

end

verstring='Oct 28, 2025'

FAOStatEmissions=a;
