load /Library/IonE/data/misc/SageNeighborhood_Ver10.mat 
    disp('Begin filling application rate gaps from neighboring countries')
    for c = 1:length(croplist)
        cropname = croplist{c};
        disp(['Filling in data for ' cropname]);
        titlestr = [cropname '_' nutrient '_ver' verno ];
        %%%%    DS = OpenNetCDF(filestr);
        appratemap=DataStoreGateway([titlestr '_rate']);

        ii = find(appratemap < -100);
        appratemap(ii) = 0;
        
        ctries_wodata = {};
        ctries_withdata = {};
        
        % loop through all ctries to find out if they are missing data (-9)
        
        for k = 1:length(fao_ctries)
            
            countrycode = fao_ctries{k};
            
            ii = strmatch(countrycode, co_codes);
            tmp = co_numbers(ii);
            ii = find(co_outlines == tmp);
            outline = zeros(4320,2160);
            outline(ii) = 1;
            
            ratetemp=appratemap .* outline;
            ratetemp=ratetemp(CropMaskIndices);
            ratetemp=ratetemp(~isnan(ratetemp));
            uniquerates = unique(ratetemp);
            tmp = find(uniquerates == 0);
            uniquerates(tmp) = [];
                        
            if uniquerates == -9;
                % it is ... let's add it to missing data list
                ctries_wodata{end+1} = countrycode;
            else
                ctries_withdata{end+1} = countrycode;
            end
        end
        
        % now we know who is missing data ... need to fill in gaps from
        % neighbors
        
        for k = 1:length(ctries_wodata);
            countrycode =  ctries_wodata{k}
            
            Apprate=GetApprateFromNeighbors(...
                countrycode,co_codes,co_outlines,co_numbers,ctries_withdata);
       
            
            
            
            
            
            
        end
        
            
            
               
               
               
                sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')
               
                
                if length(NeighborCodesSage)>0% there are neighbors
                    
                   
                    
                    
                  
                    
                    if ~isempty(ratelist)
                        
                        %%%%% THIS NEEDS MORE WORK - weight the average by the
                        %%%%% border length? also - how to prevent this from
                        %%%%% grabbing data from countries who have received an
                        %%%%% average rate ... ie. don't want an average
                        %%%%% spreading across Asia!
                        
                        avgneighbor = mean(ratelist);
                        
                        % list the countries
                        %%%%% THIS LISTS ALL NEIGHBORS< NOT JUST ONES WITH DATA
                        neighborlist = [];
                        for co = 1:length(NeighborNamesSage);
                            tmp = NeighborNamesSage{co};
                            neighborlist = [neighborlist '; ' tmp];
                        end
                        
                        disp(['Filling in data for ' sagecountryname ' with' ...
                            ' average application rate data from ' neighborlist]);
                        
                        ii = find(ctry_appratemap == -9);
                        appratemap(ii) = avgneighbor;
                        
                    end
                    
                else
                    disp(['No neighbors available for ' sagecountryname]);
                end
            end
        end
        
        DataStoreGateway([titlestr '_rate'],appratemap);
    end
    
    % Match everything up with FAO consumption & save total nutrient
    % application
    
    disp('Match everything up with FAO consumption');
    scalingmap = ones(4320,2160);
    
    fao_ctries = unique(faoinput.ctry_codes);
    fao_ctries = fao_ctries(2:length(fao_ctries)); % NOTE: DOING THIS B/C
    % MATLAB PUTS A WEIRD '' ENTRY IN THE FAO_CTRIES LIST WHEN IT IS READ
    % IN. NOT SURE HOW ELSE TO FIX THIS.
    
    for k = 1:length(fao_ctries)
        countrycode = fao_ctries{k};
        
        % Find the rows with data for this country:
        ctryrows = strmatch(countrycode, faoinput.ctry_codes);
        % Find the row with the nutrient of interest:
        tmp = strmatch(nutrient, faoinput.nutrient(ctryrows));
        datarow = ctryrows(tmp);
        country = faoinput.countries{datarow};
        disp(['Calculating the total ' nutrient  ...
            ' consumption for ' country]);
        
        faoavg = faoinput.avg_0307(datarow);
        
        % Now build an outline for this country
        
        ii = strmatch(countrycode, co_codes);
        tmp = co_numbers(ii);
        ii = find(co_outlines == tmp);
        outline = zeros(4320,2160);
        outline(ii) = 1;
        
        % build total consumption for this country
        
        country_consumption = 0;
        
        for c = 1:length(croplist)
            
            cropname = croplist{c};
 
            titlestr = [cropname '_' nutrient '_ver' verno ];
            appratemap=DataStoreGateway([titlestr '_rate']);
            areamap=DataStoreGateway([titlestr '_area']);

           
            
            jj = find(appratemap < 0); % put all no data and -9 values to zero
            appratemap(jj) = 0;
            jj = find(isnan(appratemap)); % put all no data and -9 values to zero
            appratemap(jj) = 0;
            jj = find(areamap < 0); % put all no data and -9 values to zero
            areamap(jj) = 0;
            jj = find(isnan(areamap)); % put all no data and -9 values to zero
            areamap(jj) = 0;
            
            crop_consmap = (areamap.*appratemap.*outline);
            crop_cons = sum(sum(crop_consmap));
            
            country_consumption = country_consumption + crop_cons;
        end
        
        % make sure we aren't dividing by zero ...
        if country_consumption == 0;
        else
            scalar = str2double(faoavg) ./ country_consumption;
            scalingmap(ii) = scalar;
        end
        
    end
    
    totalnutrientmap = zeros(4320,2160);
    
    for c = 1:length(croplist)
        cropname = croplist{c};
        disp(['Scaling ' cropname ' data to ensure FAO consistency']);
        filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];

        titlestr = [cropname '_' nutrient '_ver' verno ];
        appratemap=DataStoreGateway([titlestr '_rate']);
               
        ii = find(appratemap < -100);
        appratemap(ii) = NaN;
        appratemap = appratemap .* scalingmap;
        
        DS.Data=appratemap;
        DS.Data(:,:,2)=areamap;
        DS.Data(:,:,3) = scalingmap; % save the scaling map to level 3 for
        % reference purposes
        titlestr = [cropname '_' nutrient '_apprate_ver' verno];
        filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
   clear DAS
        titlestr = [nutrient '_apprate_ver' verno];
    filestr = [nutrient '_apprate_ver' verno '.nc'];
    unitstr = ['tons/ha ' nutrient];
    DAS.units=unitstr;
    DAS.title=titlestr;
    DAS.missing_value=-9e10;
    DAS.underscoreFillValue=-9e10;
    WriteNetCDF(DS.Data,titlestr,filestr,DAS,'Force');
        
        % find total nutrient application
        appratemap(ii) = 0;
        appratemap(appratemap == -9) = 0;
        croparea = DS.Data(:,:,2);
        ii = find(croparea < -100);
        croparea(ii) = 0;
        croparea = croparea .* gridcellareas; % convert from grid cell
        % fraction to hectares
        cn_app = appratemap .* croparea;
        
        % add to total nutrient map
        totalnutrientmap = totalnutrientmap + cn_app;
        
    end
    
    % save the total nutrient map
    
    titlestr = [nutrient '_totalapp_ver' verno];
    filestr = [nutrient '_totalapp_ver' verno '.nc'];
    unitstr = ['tons ' nutrient];
    DAS.units=unitstr;
    DAS.title=titlestr;
    DAS.missing_value=-9e10;
    DAS.underscoreFillValue=-9e10;
    WriteNetCDF(totalnutrientmap,titlestr,filestr,DAS);
    