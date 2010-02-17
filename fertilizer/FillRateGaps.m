% % % % %load ([IoneDataDir 'misc/SageNeighborhood_Ver10.mat'])
% % % % disp('Begin filling application rate gaps from neighboring countries')
% % % % for c = 129:length(croplist)
% % % %     cropname = croplist{c};
% % % %     disp(['Filling in data for ' cropname]);
% % % %     titlestr = [cropname '_' nutrient '_ver' verno ];
% % % %     appratemap=DataStoreGateway([titlestr '_rate']);
% % % %     
% % % %     ii = find(appratemap < -100);
% % % %     appratemap(ii) = 0;
% % % %     
% % % %     ctries_wodata = {};
% % % %     ctries_withdata = {};
% % % %     ctries_nocrop = {};
% % % %     
% % % %     % loop through all ctries to find out if they are missing data (-9)
% % % %     
% % % %     for k = 1:length(fao_ctries)
% % % %         
% % % %         ratelist = [];
% % % %         
% % % %         countrycode = fao_ctries{k};
% % % %         
% % % %         ii = strmatch(countrycode, co_codes);
% % % %         tmp = co_numbers(ii);
% % % %         ii = find(co_outlines == tmp);
% % % %         outline = zeros(4320,2160);
% % % %         outline(ii) = 1;
% % % %         
% % % %         ratetemp=appratemap .* outline;
% % % %         ratetemp=ratetemp(CropMaskIndices);
% % % %         ratetemp=ratetemp(~isnan(ratetemp));
% % % %         uniquerates = unique(ratetemp);
% % % %         tmp = find(uniquerates == 0);
% % % %         uniquerates(tmp) = [];
% % % %         
% % % %         if uniquerates == -9;
% % % %             % it is ... let's add it to missing data list
% % % %             ctries_wodata{end+1} = countrycode;
% % % %         else
% % % %             if isempty(uniquerates)
% % % %                 ctries_nocrop{end+1} = countrycode;
% % % %             else
% % % %                 ctries_withdata{end+1} = countrycode;
% % % %             end
% % % %         end
% % % %     end
% % % %     
% % % %     % now we know who is missing data ... need to fill in gaps from
% % % %     % neighbors
% % % %     
% % % %     for k = 1:length(ctries_wodata);
% % % %         countrycode =  ctries_wodata{k};
% % % %         
% % % %         [appratemap]=GetApprateFromSimilar(...
% % % %             countrycode,co_codes,co_outlines,co_numbers,ctries_withdata,appratemap);
% % % %         
% % % % % % %         sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')
% % % % % % %         
% % % % % % %         neighborlist = [];
% % % % % % %         for k = 1:length(Neighbors);
% % % % % % %             tmp = Neighbors{k};
% % % % % % %             neighborlist = [neighborlist '; ' tmp];
% % % % % % %         end
% % % % % % %         disp(['Filling in data for ' sagecountryname ' with' ...
% % % % % % %             ' average application rate data from ' neighborlist]);
% % % % % % %         
% % % % % % %         ii = strmatch(countrycode, co_codes);
% % % % % % %         tmp = co_numbers(ii);
% % % % % % %         ii = find(co_outlines == tmp);
% % % % % % %         outline = zeros(4320,2160);
% % % % % % %         outline(ii) = 1;
% % % % % % %         
% % % % % % %         ctry_appratemap=appratemap .* outline;
% % % % % % %         
% % % % % % %         ii = find(ctry_appratemap == -9);
% % % % % % %         appratemap(ii) = avgneighbor;
% % % %         
% % % %     end
% % % %     DataStoreGateway([titlestr '_rate'],appratemap);
% % % % end
% % % % 
% % % % 
% % % % 
% % % % 
% % % % % Match everything up with FAO consumption & save total nutrient
% % % % % application
% % % % 
% % % % disp('Match everything up with FAO consumption');
% % % % scalingmap = ones(4320,2160);
% % % % 
% % % % fao_ctries = unique(faoinput.ctry_codes);
% % % % fao_ctries = fao_ctries(2:length(fao_ctries)); % NOTE: DOING THIS B/C
% % % % % MATLAB PUTS A WEIRD '' ENTRY IN THE FAO_CTRIES LIST WHEN IT IS READ
% % % % % IN. NOT SURE HOW ELSE TO FIX THIS.


%%%%%%%%%%%%NEED TO CHANGE BACK!!!!!!!!!!!!!!!!
for k = 57:length(fao_ctries)
    countrycode = fao_ctries{k};
    
    % Find the rows with data for this country:
    ctryrows = strmatch(countrycode, faoinput.ctry_codes);
    country = faoinput.countries{ctryrows(1)};
    % Find the row with the nutrient of interest:
    tmp = strmatch(nutrient, faoinput.nutrient(ctryrows));
    if tmp > 0
    datarow = ctryrows(tmp);
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
    else
        disp(['No ' nutrient ' entry for ' country]);
    end
    
end

totalnutrientmap = zeros(4320,2160);

%% Scale data to ensure FAO consistency & calculate crop consumption

% create output structure to store crop by crop total consumption data

outputstructure.croplist = {};
outputstructure.cropcons = [];

% create netcdf output folder
mkdir('netcdfs');

for c = 1:length(croplist)
    cropname = croplist{c};
    disp(['Scaling ' cropname ' data to ensure FAO consistency']);
    
    
    cropname = croplist{c};
    
    titlestr = [cropname '_' nutrient '_ver' verno ];
    appratemap=DataStoreGateway([titlestr '_rate']);
    areamap=DataStoreGateway([titlestr '_area']);
    ii = isnan(areamap);
    areamap(ii) = 0; % not sure if we want to keep this going to zero ...
    
    
    appratemap = appratemap .* scalingmap;
    ii = isnan(appratemap);
    appratemap(ii) = 0; % not sure if we want to keep this going to zero ...
    DataStoreGateway([titlestr '_rate'],appratemap);
    
    Data=appratemap;
    Data(:,:,2)=areamap;
    Data(:,:,3) = scalingmap; % save the scaling map to level 3 for
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
    
    % go to netcdf output folder and write data
    
    cd('netcdfs');
    
    WriteNetCDF(Data,titlestr,filestr,DAS,'Force');
    
    % go back to 'regular' output folder
    cd ../;
    
    % find total nutrient application
    
    jj = find(appratemap < 0); % put all no data and -9 values to zero
    appratemap(jj) = 0;
    jj = find(isnan(appratemap)); % put all no data and -9 values to zero
    appratemap(jj) = 0;
    jj = find(areamap < 0); % put all no data and -9 values to zero
    areamap(jj) = 0;
    jj = find(isnan(areamap)); % put all no data and -9 values to zero
    areamap(jj) = 0;
    
    areamap = areamap .* gridcellareas; % convert from grid cell
    % fraction to hectares
    cn_app = appratemap .* areamap;
    
    % add to total nutrient map
    totalnutrientmap = totalnutrientmap + cn_app;
    
    % calculate quantity consumed for this crop
    crop_cons = sum(sum(cn_app));
    outputstructure.croplist{c} = cropname;
    outputstructure.cropcons(c) = crop_cons;
    
end

% save the total nutrient map

titlestr = [nutrient '_totalapp_ver' verno];
filestr = [nutrient '_totalapp_ver' verno '.nc'];
unitstr = ['tons ' nutrient];
DAS.units=unitstr;
DAS.title=titlestr;
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;

% go to netcdf output folder and write data

cd('netcdfs');

WriteNetCDF(totalnutrientmap,titlestr,filestr,DAS);

% go back to 'regular' output folder
cd ../;

% save the outputstructure for this nutrient
eval(['save ' nutrient '_outputdata outputstructure;']);


