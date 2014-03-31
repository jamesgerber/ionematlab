function OS=countrydatagateway(year,code,codeID,fieldlist);
% pslcountrydatagateway - get country-level data
%
% Syntax OS=countrydatagateway(year,code,codeID,fieldlist);
%
%
%    Example ah=countrydatagateway(1995,3,'faostatcode',{'USDA_FAS','Wheat','Area_Harvested'});
%
%    This will return Wheat Area_Harvested for faostat country 3 for the
%    year 1995

persistent countrycodes
if isempty(countrycodes)
    countrycodes=ReadGenericCSV('/psldata/humangeography/admincodes/countrycodes_RevB.txt',2,tab,1);
end


% first task:  let's get ISO3 code for this country

[ISO3Code,UN_Name]=GetISO3Code(code,codeID,countrycodes);





switch lower(fieldlist{1})
    case 'usda_fas'
        cropname=fieldlist{2};
        attribute=fieldlist{3};
        
        csvfilename= [psldatastring '/commerce/USDA_FAS/processeddata/' cropname '_' attribute '.csv'];
        matfilename= [psldatastring '/commerce/USDA_FAS/processeddata/' cropname '_' attribute '_csv.mat'];
        
        if exist(matfilename)==2
            load(matfilename)
        else
            data=readgenericcsv([  csvfilename],4);
            save(matfilename,'data');
        end
        % let's get ISO3 name for this country
        
        ii=find(data.year==year);
        kk=strmatch(ISO3Code,data.ISO3);
        jj=intersect(ii,kk);
        
        if isempty(jj) | isempty(ISO3Code)
            disp(['found no match to data for ' UN_Name]);
            outputdata=NaN;
        else   
            outputdata=data.value(jj);
        end
        
        OS=outputdata;
        
    otherwise
        error(['don''t have infrastructure in ' mfilename ' to find ' fieldlist{1} ]);
end

