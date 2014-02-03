function USDAFASPSD_mapandfile(DS,IONE_AdminUnits,USDAcountries,...
    Attribute_ID,Commodity_Code,Market_Year,...
    HeaderLineStructure,filebase,attributes,commodities);
%USDAFASPSD_mapandfile(PSDDataDataStructure,IONE_AdminUnits,USDAcountries,...
%    Attribute_ID,Commodity_Code,Market_Year,filename,...
%    commodityname,attributename,HeaderLineStructure,filebase,...
%    attributes,commodities);
%
%  Version 2 - i'm idiot proofing this for myself the the following
%  changes:
%
%  1)  construct filename here
%  2)  look up attribute name
%  3)  throw ISO3 and sage codes into output files.
%


ii=attributes.attribute_id==Attribute_ID;
AttributeName=MakeSafeString(attributes.attribute_description{ii});


ii=commodities.cm_code==Commodity_Code;
CommodityName=MakeSafeString(commodities.cm_description{ii});

filename=[filebase '/' CommodityName '_' AttributeName ];

if exist([filename num2str(Market_Year(end)) '.mat'])
    disp([' already have ' filename ])
    return
end



fid=fopen([filename '.csv' ],'w')

for j=1:length(HeaderLineStructure)
    fprintf(fid,'%s\n',HeaderLineStructure{j});
end
fprintf(fid,'Sage3,ISO3,adminunitname,adminunitcode,commodityname,attributename,year,value\n');

verbose=1;

for yr=Market_Year
    
    %for month=7
    ii=find([DS.Attribute_ID]==Attribute_ID & ...
        [DS.Commodity_Code]==Commodity_Code & ...
        [DS.Market_Year]==yr ...
        );
    
    
    newmap=datablank(-9999);   % make a template matrix on which we will spatialize the data.
    
    % prepforfancystuff below
    ReducedCountryCode=DS.Country_Code(ii);
    
    
    for j=1:length(USDAcountries);       

        c2=USDAcountries{j};  %"c2" because it is a 2-letter country code.
        %%% a slow line
        %        jj=strmatch(c2,DS.Country_Code);
   %%% much faster way to do it ... only search where it's even possible.
   mm=strmatch(c2,ReducedCountryCode);
   jj=ii(mm);


        idx=strmatch(c2,IONE_AdminUnits.Unknown_Code,'exact');  % HERE IS A CHANGE
        if ~isempty(idx)
            Sage3=IONE_AdminUnits.Sage3{idx};
            ISO3=IONE_AdminUnits.ISO3{idx};
            adminunitname=IONE_AdminUnits.UN_Name{idx};  % replace with GADM or naturalearth
            adminunitcode=IONE_AdminUnits.UN_Numerical_Code{idx};  % replace with GADM or naturalearth
            adminunitcode=str2num(adminunitcode);
            if ~isempty(Sage3)
                
                mm=intersect(ii,jj);
                
                if isempty(mm)
                    if verbose==1
                        disp(['found nothing for ' IONE_AdminUnits.Unknown_Name(idx) ' year ' num2str(yr) '' ]);
                    end
                else
                    if length(mm) >1
                        disp(['multiple months'])
                        keyboard
                    else
                        if verbose==1
                            disp(['found data for ' IONE_AdminUnits.Unknown_Name(idx) ' year ' num2str(yr) '' ]);
                        end
                        % add to map
                        kk=CountryCodetoOutlineVector(Sage3);
                        newmap(kk)=DS.Value(mm);
                        % add to file
                        
                        fprintf(fid,'%s,%s,%s,%d,%s,%s,%d,%f\n',...
                            Sage3,ISO3,adminunitname,adminunitcode,CommodityName,...
                            AttributeName,yr,DS.Value(mm));
                    end
                end
            end
        end
    end
    
    save([filename num2str(yr)],'newmap','HeaderLineStructure');
    
end

fclose(fid)


