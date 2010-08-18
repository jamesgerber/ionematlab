% fertilizermaps_v1_6.m
%
% A program to make maps of subnational fertilizer application by crop and
% by nutrient. Written by Nathan Mueller.
%
% Version 1 - 1.23.2010 - Uses IFAFAO database from Phil and Navin -
% basically just replicating what they did using updated crop proxies.
%    v1.1 Various bug-fixes. Edited to use new paths for crops directory.
%    v1.2 Optimized to use hash tables. Fixed bug so netcdfs saved
%    properly.
%    v1.3 Update to make unique maps for every crop proxy in the proxylist.
%    Added capability to scale this output to FAO total consumption.
%    v1.5 Version used to make poster. Fill rate gaps with countries of
%    similar economic status.
%    v1.6 Fill rate gaps from similar economic status had been deleted.
%    Added this back in. Added hash table for country row look-up. Fixed
%    the seasonal barley and wheat issue by creating national-level
%    weighted-average application rates for the two crops. The underlying
%    data is preserved in the input file for future use. Added subnational
%    scaling procedures 1 and 2.
%    v1.7 Eliminated crop_2000 extrapolation; Apply "other crop" data to
%    missing crops when possible before doing income extrapolation; Created
%    a horticulture map in the beginning.



%% initialize diary and time record

ds = datestr(now);
diaryfilename = ['fertrunoutput ' ds '.txt'];
diary(diaryfilename);
disp(diaryfilename);
tic;



%% record the version number
verno = '1_7';
disp(['You are running version ' verno ' of fertilizermaps'])



%% read input files

% load fertilizer data file
inputfile = ReadGenericCSV('subnationalfert4.csv');
save fertinput
% load fertinput

% inputarray = {};
% fn = fieldnames(inputfile);
% for c = 1:length(fn);
% inputarray{1,c} = fn{c};
% eval(['datacol = inputfile.' fn{c} ';'])
% inputarray(2:(length(datacol)+1),c) = datacol;
% end

% load crop proxy list (this equates an entry in the fertilizer data file
% to a spatially-explicit map from Monfreda et al 2008.
cropinput = ReadGenericCSV('proxylist.csv');
datalist = cropinput.datalist;
proxylist = cropinput.proxylist;

% load FAO average consumption data centered on the year 2000. **NOTE: b/c
% FAO only goes back to 2002(?), we must calibrate to data from 2002-03.
faoinput = ReadGenericCSV('FAO_0307avg.csv');
fao_ctries = unique(faoinput.ctry_codes);

% load input netcdfs
disp('Reading input netCDF files')
SystemGlobals;
path = [IoneDataDir 'misc/area_ha_5min.nc'];
[DS] = OpenNetCDF(path);
gridcellareas = DS.Data;

% load World Bank income classification info
WB = ReadGenericCSV('wbiclass.csv');



%% pre-processing of input file to speed up data lookup

% build unique list of 5-letter/number codes for state-level entries

counter = 1;
for c = 1:length(inputfile.Sage_admin)
    code = inputfile.Sage_admin{c};
    if length(code) > 3
        inputfile.Sage_state{counter} = code(1:5);
        counter = counter + 1;
    end
end
statecodes = unique(inputfile.Sage_state);
tmp = strmatch('new_s',statecodes); % remove any "new_snu" issues
statecodes(tmp) = [];

% build unique list of 3-letter/number codes for country-level entries
countrycodes = unique(inputfile.ctry_code);
tmp = strmatch('new',countrycodes); % remove any "new_snu" issues
countrycodes(tmp) = [];
tmp = strmatch('"IFA/FAO/IFDC_FUBC_5_dataset',countrycodes);
countrycodes(tmp) = [];

% add "row_htable" hash table for inputfile - this will return the row
% indices for any SAGE admin code (country, state, or county-level).
if ~exist('row_htable')
    row_htable = java.util.Properties;
    for j=1:length(countrycodes);
        ii=strmatch(countrycodes{j},inputfile.ctry_code);
        row_htable.put(countrycodes{j},ii);
    end
    for j=1:length(statecodes)
        ii=strmatch(statecodes{j},inputfile.Sage_state);
        row_htable.put(statecodes{j},ii);
    end
    for j=1:length(inputfile.Sage_admin)
        ii=strmatch(inputfile.Sage_admin{j},inputfile.Sage_admin);
        row_htable.put(inputfile.Sage_admin{j},ii);
    end
end



%% pre-processing of crop list data

% Create a list of unique crop types we'll make fertilizer application maps
% for. This map is created from all the unique proxies in the proxylist.
disp('Building list of unique crop types')
tmp = {};
for n = 1:length(proxylist);
    str = proxylist{n};
    % below is Jamie's code to convert the list of proxies into a cell array
    clear proxycellarray
    str=strrep(str,' ','');
    str=strrep(str,'"','');
    str(end+1)='+';
    ii=find(str=='+');
    proxycellarray = {};
    proxycellarray{1}=str(1:ii(1)-1);
    for j=1:(length(ii)-1)
        proxycellarray{j+1}=str(ii(j)+1:ii(j+1)-1);
    end
    % create a master list & find unique values
    x = length(tmp);
    for c = 1:length(proxycellarray);
        y = x + c;
        tmp{y} = proxycellarray{c};
    end
end
croplist = unique(tmp(:));



%% Make a horticulture map & initialize data files

% NOTE: b/c the amounts of
% fertilized horticultural area are (obviously!) much lower than
% the total area in the cropland map (which we are using b/c there
% is no "horticulture" map) ... we want to scale each country's
% horticulture map down so that the total area is equivalent to the
% IFA/FAO/IFDC statistic on how much horticulture land
% was fertilized in a given country.

% first grab the Ramankutty et al 2008 cropland map (crop_2000)
cropname = 'crop_2000';
x = ([cropname '_5min.nc']);
path = [IoneDataDir 'Crops2000/crops/' x];
[DS] = OpenNetCDF(path);
areamap = DS.Data(:,:,1);
jj = find(areamap>1e20);
areamap(jj) = NaN;

% next adjust the map according to the amount of horticultural land is in
% each country
dataentry = 'horticulture';
nutrient = 'N'; % NOTE: b/c the areas fertilized for each crop in
% IFA/FAO/IFDC database are the same for each nutrient, I can get
% away with just looking at the pasture areas for nitrogen.
areahamap = areamap .* gridcellareas;
croplandmap = areahamap;
ii = find(isnan(croplandmap));
croplandmap(ii) = 0;
areahamap = zeros(4320,2160);
for c = 1:length(countrycodes);
    ccode = countrycodes{c};
    areaheader = [dataentry '_' nutrient '_areafert'];
    eval(['areacol = inputfile.' areaheader ';']);
    ctryrows = row_htable.get(ccode);
    tmp = strmatch('country data', inputfile.Name_1(ctryrows));
    countrydatarow = ctryrows(tmp);
    IFAhortarea = str2double(areacol{countrydatarow});
    if IFAhortarea > 0
        [outline] = CountryCodetoOutline(ccode);
        m3croparea = sum(sum(croplandmap.*outline));
        scalar = IFAhortarea ./ m3croparea;
        tmp = croplandmap .* outline .* scalar;
        areahamap = areahamap + tmp;
        if isnan(sum(sum(areahamap)))
            disp('problem')
        end
    end
end
disp('Saving horticulture area map');
areamap = areahamap ./ gridcellareas;
cropname = 'horticulture';
for n = 1:3
    switch n
        case 1
            nutrient = 'N';
        case 2
            nutrient = 'P';
        case 3
            nutrient = 'K';
    end
    titlestr = [cropname '_' nutrient '_ver' verno];
    DataStoreGateway([titlestr '_area'],areamap);
end



%% build total fertilized land map and initialize data files
disp('Building total fertilized land map');
totfertlandmap = zeros(4320,2160);
for i = 1:length(croplist);
    cropname = croplist{i};
    disp(['Initializing files for ' cropname]);
    if strmatch(cropname, 'horticulture')
        titlestr = [cropname '_' nutrient '_ver' verno];
        areamap = DataStoreGateway([titlestr '_area']);
    else
        x = ([cropname '_5min.nc']);
        path = [IoneDataDir 'Crops2000/crops/' x];
        [DS] = OpenNetCDF(path);
        areamap = DS.Data(:,:,1);
        jj = find(areamap>1e20);
        areamap(jj) = NaN;
    end
    ii = find(areamap < 2 & areamap > 0);
    appratemap = nan(4320,2160);
    appratemap(ii) = -9; % put -9 where we know we have crop data ...
    % but we do not (at least yet) know the application rate
   
    % save the data files
    appratemap = single(appratemap);
    areamap = single(areamap);
    for n = 1:3
        switch n
            case 1
                nutrient = 'N';
            case 2
                nutrient = 'P';
            case 3
                nutrient = 'K';
        end
        titlestr = [cropname '_' nutrient '_ver' verno];
        DataStoreGateway([titlestr '_rate'],appratemap);
        DataStoreGateway([titlestr '_datatype'],appratemap);
        DataStoreGateway([titlestr '_area'],areamap);
    end
   
    % add to total fertilized land map
    areamap(jj) = 0;
    areahamap = areamap .* gridcellareas;
    totfertlandmap = totfertlandmap + areahamap;
end



%% fix the spring/summer/winter wheat & barley problem
% NOTE: this only works for national-level data right now; as there is not
% subnational, crop-specific information for these crops in the affected
% countries, there is nothing to worry about! In the future this may need
% to be changed though.

disp(['Averaging national-level application rate data for seasonal' ...
    ' varieties of wheat and barley']);

for n = 1:3
    switch n
        case 1
            nutrient = 'N';
        case 2
            nutrient = 'P';
        case 3
            nutrient = 'K';
    end
    disp(['Begin calculating weighted averages for ' nutrient ...
        ' application rates'])
    
    for i = 1:2
        switch i
            case 1
                crop = 'barley';
            case 2
                crop = 'wheat';
        end
        
        for s = 1:4;
            switch s
                case 1
                    season = '';
                case 2
                    season = '_spring';
                case 3
                    season = '_summer';
                case 4
                    season = '_winter';
            end
            
            disp(['Getting data columns for ' nutrient ...
                ' ' season ' ' crop ' data'])
            dataentry = [crop season];
            dataheader = [dataentry '_' nutrient '_data'];
            areaheader = [dataentry '_' nutrient '_areafert'];
            eval(['datacol_' num2str(s) ' = inputfile.' dataheader ';']);
            eval(['areacol_' num2str(s) ' = inputfile.' areaheader ';']);
        end
        
        for k = 1:length(fao_ctries)
            countrycode = fao_ctries{k};
            
            % Find the rows with data for this country:
            ctryrows=row_htable.get(countrycode);
            
            % Find the rows for data type, source, and the country-level
            % data
            tmp = strmatch('data type', inputfile.Name_1(ctryrows));
            datatyperow = ctryrows(tmp);
            tmp = strmatch('data source', inputfile.Name_1(ctryrows));
            datasourcerow = ctryrows(tmp);
            tmp = strmatch('country data', inputfile.Name_1(ctryrows));
            countrydatarow = ctryrows(tmp);
            country = inputfile.Cntry_name{datatyperow};
            
            for s = 1:4;
                eval(['datatype_' num2str(s) ' = str2double(datacol_' ...
                    num2str(s) '{datatyperow});']);
                eval(['datasource_' num2str(s) ' = datacol_' ...
                    num2str(s) '{datasourcerow};']);
                eval(['countrydata_' num2str(s) ' = str2double(datacol_'...
                    num2str(s) '{countrydatarow});']);
                eval(['countryarea_' num2str(s) ' = str2double(areacol_'...
                    num2str(s) '{countrydatarow});']);
            end
            
            WAflag = 1;
            
            if countrydata_1 < 0
                if countrydata_2 < 0
                    if countrydata_3 < 0
                        if countrydata_4 < 0
                            disp(['no ' crop ' ' nutrient ...
                                ' data for ' country]);
                            WAflag = 0;
                        end
                    end
                end
            elseif countrydata_2 < 0
                if countrydata_3 < 0
                    if countrydata_4 < 0
                        disp(['only regular ' crop ' ' nutrient ...
                            ' data for ' country]);
                        WAflag = 0;
                    end
                end
            end
            if WAflag == 1;
                % switch -9 no data values for both application rate and
                % area to 0 for purposes of calculating a weighted average
                for s = 1:4;
                    eval(['countrydata = countrydata_' num2str(s) ';']);
                    eval(['countryarea = countryarea_' num2str(s) ';']);
                    if countrydata < 0
                        countrydata = 0;
                    end
                    if countryarea < 0
                        countryarea = 0;
                    end
                    eval(['countrydata_' num2str(s) ' = countrydata;']);
                    eval(['countryarea_' num2str(s) ' = countryarea;']);
                end
                
                totalcroparea = countryarea_1 + countryarea_2 + ...
                    countryarea_3 + countryarea_4;
                
                ratexarea_1 = countryarea_1 .* countrydata_1;
                ratexarea_2 = countryarea_2 .* countrydata_2;
                ratexarea_3 = countryarea_3 .* countrydata_3;
                ratexarea_4 = countryarea_4 .* countrydata_4;
                
                totalratexarea = ratexarea_1 + ratexarea_2 + ...
                    ratexarea_3 + ratexarea_4;
                
                WA_rate = totalratexarea ./ totalcroparea;
                
                disp(['weighted average for ' crop ...
                    ' ' nutrient ' in ' country ': ' num2str(WA_rate) ...
                    ' kg/ha ' nutrient ', ' num2str(totalcroparea) ...
                    ' total ha cropland']);
                
                % save the rate and area in the proper data columns
                
                dataheader = [crop '_' nutrient '_data'];
                areaheader = [crop '_' nutrient '_areafert'];
                eval(['datacol = inputfile.' dataheader ';']);
                eval(['areacol = inputfile.' areaheader ';']);
                
                datacol{countrydatarow} = num2str(WA_rate);
                areacol{countrydatarow} = num2str(totalcroparea);
                
                % save the data type: **NOTE** this is hardcoded as data
                % type 3 for the time being since we are only dealing with
                % national-level data
                
                datacol{datatyperow} = '3';
                areacol{datatyperow} = '3';
                
                % save the data source
                
                for s = 1:4
                    eval(['datasource = datasource_' num2str(s) ';']);
                    if datasource == -9
                    else
                        sourcetosave = datasource;
                    end
                end
                
                datacol{datasourcerow} = sourcetosave;
                areacol{datasourcerow} = sourcetosave;
                
                % save to inputfile
                
                eval(['inputfile.' dataheader ' = datacol;']);
                eval(['inputfile.' areaheader ' = areacol;']);
                
            end
        end
    end
end

% remove the seasonal data entries from the datalist
tmp = datalist([1:9 13:151 155]);
datalist = tmp;
tmp = proxylist([1:9 13:151 155]);
proxylist = tmp;

% delete some extra files after pre-processing
clear datacol datacol_1 datacol_2 datacol_3 datacol_4
clear areacol areacol_1 areacol_2 areacol_3 areacol_4
clear m3pastmap



%% save the input stuff after it is complete!

save fertworking



%% loop through fertilizer application rate data from inputfile

for n = 1:3
    switch n
        case 1
            nutrient = 'N';
        case 2
            nutrient = 'P';
        case 3
            nutrient = 'K';
    end
    
    disp(['Begin working on ' nutrient ' data from the input file'])
    
    % cycle through the countries
    for k = 1:length(fao_ctries)
        countrycode = fao_ctries{k};
        
        % Find the rows with data for this country:
        ctryrows=row_htable.get(countrycode);
        
        % Create a list for ctryrows minus the data type row,
        % country data row, and data source row
        subnationalrows = ctryrows;
        subnationalrows([1, 2, 3]) = [];
        
        % Find the rows for data type, source, and the
        % country-level data
        tmp = strmatch('data type', inputfile.Name_1(ctryrows));
        datatyperow = ctryrows(tmp);
        tmp = strmatch('data source', inputfile.Name_1(ctryrows));
        datasourcerow = ctryrows(tmp);
        tmp = strmatch('country data', inputfile.Name_1(ctryrows));
        countrydatarow = ctryrows(tmp);
        country = inputfile.Cntry_name{datatyperow};
        
        % cycle through the data entries
        for datano = 1:length(datalist)
            dataentry = datalist{datano};
            
            disp(['Working on ' dataentry ' ' nutrient ' data' ...
                'in ' country])
            
            dataheader = [dataentry '_' nutrient '_data'];
            areaheader = [dataentry '_' nutrient '_areafert'];
            
            eval(['datacol = inputfile.' dataheader ';']);
            eval(['areacol = inputfile.' areaheader ';']);
            
            tmp = strmatch(dataentry, datalist);
            str = proxylist{tmp};
            
            % below is Jamie's code to convert the list of proxies into a cell
            % array
            clear proxycellarray
            str=strrep(str,' ','');
            str=strrep(str,'"','');
            str(end+1)='+';
            ii=find(str=='+');
            proxycellarray = {};
            proxycellarray{1}=str(1:ii(1)-1);
            for j=1:(length(ii)-1)
                proxycellarray{j+1}=str(ii(j)+1:ii(j+1)-1);
            end
            
            % get the data type, source, and app rate data for the country
            % and data entry
            datatype = str2double(datacol{datatyperow});
            datasource = datacol{datasourcerow};
            countrydata = str2double(datacol{countrydatarow});
            
            if (datatype > 0)
                
                % cycle through crop proxies
                for c = 1:length(proxycellarray);
                    cropname = proxycellarray{c};
                    titlestr = [cropname '_' nutrient '_ver' verno];
                    appratemap = DataStoreGateway([titlestr ...
                        '_rate']);
                    datatypemap = DataStoreGateway([titlestr ...
                        '_datatype']);
                    
                    % *** ADJUST APP RATES IF THE DATA IS FOR PASTURE ***
                    % is this pasture data? if so, we must adjust the
                    % application rates based on the amount of fertilized
                    % pasture land
                    if strmatch('past', cropname)
                        
                        % get a map of M3 pastureland
                        m3pastmap = DataStoreGateway([titlestr '_area']);
                        m3pastmap = m3pastmap .* gridcellareas;
                        ii = find(isnan(m3pastmap));
                        m3pastmap(ii) = 0;
                        
                        % is this from "crop group pasture and fodder"? if
                        % so we must calculate fertilized pasture land as
                        % IFA cg_pastureandfodder land - M3 crop areas for
                        % all the fodder crops in the group. we assume the
                        % remaining fertilized land is pasture land.
                        if strmatch('cg', dataentry)
                            
                            foddermap = zeros(4320,2160);
                            % sum up areas of all the fodder crops (the
                            % first proxy is pasture, so we skip that
                            % entry in the proxy cell array)
                            for x = 2:length(proxycellarray)
                                proxyname = proxycellarray{x};
                                titlestr2 = [proxyname '_' nutrient '_ver' verno];
                                areamap = DataStoreGateway([titlestr2 '_area']);
                                areahamap = areamap .* gridcellareas;
                                ii = find(isnan(areahamap));
                                areahamap(ii) = 0;
                                foddermap = foddermap + areahamap;
                            end
                            [outline] = CountryCodetoOutline(countrycode);
                            fodderarea = sum(sum(foddermap.*outline));
                            areaheader = [dataentry '_' nutrient '_areafert'];
                            eval(['areacol = inputfile.' areaheader ';']);
                            tmp = str2double(areacol{countrydatarow});
                            IFApastarea = tmp - fodderarea;
                            
                            clear foddermap
                            
                        else
                            % for pasture data not from the crop group,
                            % just get the pasture area from the input file
                            areaheader = [dataentry '_' nutrient '_areafert'];
                            eval(['areacol = inputfile.' areaheader ';']);
                            IFApastarea = str2double(areacol{countrydatarow});
                        end
                        
                        % if pasture area is greater than zero, then scale
                        % the application rates appropriately and use the
                        % adjusted application rates on the pasture area
                        if IFApastarea > 0
                            [outline] = CountryCodetoOutline(countrycode);
                            m3pastarea = sum(sum(m3pastmap.*outline));
                            scalar = IFApastarea ./ m3pastarea;
                            if scalar < 1;
                                adjcountrydata = countrydata .* scalar;
                            else
                                adjcountrydata = countrydata
                            end
                        else
                            disp(['Calculated pasture area is < 0, ' ...
                                'skipping pasture application for ' ...
                                country]);
                            datatype = 0;
                        end
                        
                    else
                        % if we're not dealing with pasture, simply use the
                        % national-level application rate from the input
                        % file.
                        adjcountrydata = countrydata;
                        
                    end
                    
                    switch datatype
                        
                        case 1 % subnational, crop-specific application
                            % rate is applied directly to each crop proxy
                            
                            disp(['Processing subnational application ' ...
                                'rate data for ' dataentry ...
                                ', crop proxy: "' cropname '" in ' country])
                            
                            % cycle through each subnational political unit
                            for s = 1:length(subnationalrows);
                                snucode = inputfile.Sage_admin{subnationalrows(s)};
                                snuname1 = inputfile.Name_1{subnationalrows(s)};
                                snuname2 = inputfile.Name_2{subnationalrows(s)};
                                snudata = str2double(datacol{subnationalrows(s)});
                                
                                if isnan(snudata) % snudata will return as
                                    % NaN if no data exists for a
                                    % particular snu; if this happens need
                                    % to just use the national-level
                                    % application rate
                                    
                                    disp(['No subnational rate for '...
                                        snuname1 ' ' snuname2 ' so '...
                                        'applying national-level ' ...
                                        nutrient ' app. rate to '...
                                        'crop proxy: "' cropname '"']);
                                    
                                    outline = CountryCodetoOutline(snucode);
                                    ii = find(appratemap > -10 & outline > 0);
                                    if length(ii) < 1
                                        warning(['No cropland detected in ' ...
                                            'this SNU']);
                                    else
                                        appratemap(ii) = adjcountrydata;
                                        datatypemap(ii) = 1;
                                    end
                                    
                                else
                                    
                                    disp(['Working on application rates for '...
                                        'crop proxy: "' cropname '" in ' ...
                                        snuname1 ' ' snuname2]);
                                    
                                    outline = CountryCodetoOutline(snucode);
                                    ii = find(appratemap > -10 & outline > 0);
                                    if length(ii) < 1
                                        warning(['No cropland detected in ' ...
                                            'this SNU']);
                                    else
                                        appratemap(ii) = snudata;
                                        datatypemap(ii) = 1;
                                    end
                                end
                            end
                            
                        case 3 % national-level application rate data is
                            % applied directly to each country's crop area
                            
                            disp(['Processing national-level application ' ...
                                'rate data for ' dataentry ...
                                ', crop proxy: "' cropname '" in ' country])
                            
                            outline = CountryCodetoOutline(countrycode);
                            
                            titlestr = [cropname '_' nutrient '_ver' verno ];
                            appratemap=DataStoreGateway([titlestr '_rate']);
                            datatypemap = DataStoreGateway([titlestr ...
                                '_datatype']);
                            
                            ii = find(appratemap > -10 & outline > 0);
                            appratemap(ii) = adjcountrydata;
                            datatypemap(ii) = 3;
                            
                    end
                    DataStoreGateway([titlestr '_rate'],appratemap);
                    DataStoreGateway([titlestr '_datatype'],datatypemap);
                end
                
            else
                
                disp(['No data for ' dataentry ' in ' country]);
                
            end
        end
        
    end
    
    
%     %% Fill gaps in application rate data with "other crop" data
%     
%     % find the other crop column
%     dataentry = 'other';
%     dataheader = [dataentry '_' nutrient '_data'];
%     areaheader = [dataentry '_' nutrient '_areafert'];
%     
%     eval(['datacol = inputfile.' dataheader ';']);
%     eval(['areacol = inputfile.' areaheader ';']);
%     
%     % check to see if we have data for "other" crops in each country;
%     % create a map of the "other crop" rate for each country.
%     
%     othermap = nan(4320,2160);
%     
%     for k = 1:length(fao_ctries)
%         countrycode = fao_ctries{k};
%         
%         % Find the rows with data for this country:
%         ctryrows=row_htable.get(countrycode);
%         
%         % Create a list for ctryrows minus the data type row,
%         % country data row, and data source row
%         subnationalrows = ctryrows;
%         subnationalrows([1, 2, 3]) = [];
%         
%         % Find the rows for data type, source, and the
%         % country-level data
%         tmp = strmatch('data type', inputfile.Name_1(ctryrows));
%         datatyperow = ctryrows(tmp);
%         tmp = strmatch('data source', inputfile.Name_1(ctryrows));
%         datasourcerow = ctryrows(tmp);
%         tmp = strmatch('country data', inputfile.Name_1(ctryrows));
%         countrydatarow = ctryrows(tmp);
%         country = inputfile.Cntry_name{datatyperow};
%         
%         % get the data type, source, and app rate data for the country
%         % and data entry
%         datatype = str2double(datacol{datatyperow});
%         datasource = datacol{datasourcerow};
%         countrydata = str2double(datacol{countrydatarow});
%         
%         if (datatype > 0)
%             
%             disp(['Adding "other crop" ' nutrient ' data in ' country ...
%                 ' to the other crop map: ' num2str(countrydata) ' kg/ha']);
%             [outline,ii] = CountryCodetoOutline(countrycode);
%             othermap(ii) = countrydata;
%             
%         else
%             
%             disp(['No "other crop" ' nutrient ' data in ' country]);
%             
%         end
%     end
%         
%     % Now, for each crop, if we're missing data, use the "other crop" data
%     for c = 1:length(croplist)
%         cropname = croplist{c};
%         
%         if strmatch('horticulture', cropname);
%             disp(['Skipping extrapolation for horticulture: this is ' ...
%                 'only present to preserve total nutrient consumption ' ...
%                 'in a few countries.']);
%         else
%             
%             titlestr = [cropname '_' nutrient '_ver' verno ];
%             appratemap = DataStoreGateway([titlestr '_rate']);
%             datatypemap = DataStoreGateway([titlestr '_datatype']);
%             
%             disp(['Filling in data for ' cropname ' using the ' ...
%                 '"other crop" ' nutrient ' application rates']);
%             ii = find(isfinite(othermap) & appratemap == -9);
%             appratemap(ii) = othermap(ii);
%             datatypemap(ii) = 3.5;
%             
%             DataStoreGateway([titlestr '_rate'], appratemap);
%             DataStoreGateway([titlestr '_datatype'], datatypemap);
%             
%         end
%     end
    
    
    
    %% Fill gaps in application rate data with income-based extrapolation
    
    % Now - need to get data from neighbors to fill in gaps
    % For each crop ... Find ctries with -9s ... then look for neighbors
    % with data
    
    disp(['Begin filling application rate gaps from countries ' ...
        ' of similar economic status']);
    
    path = [IoneDataDir 'misc/wbiclass.csv'];
    WBI = ReadGenericCSV(path);
    
    WBIhtable = java.util.Properties;
    for j=1:length(WBI.countrycode);
        income = WBI.class{j};
        % get rid of divisions between OECD and non-OECD high income
        % countries
        if strmatch('High',income);
            income = 'High income';
        end
        WBIhtable.put(WBI.countrycode{j},income);
    end
    
    for c = 1:length(croplist)
        cropname = croplist{c};
        
        if strmatch('horticulture', cropname);
            disp(['Skipping extrapolation for horticulture: this is ' ...
                'only present to preserve total nutrient consumption ' ...
                'in a few countries.']);
        else
            
            disp(['Start filling in missing application rate data for ' ...
                cropname]);
            
            titlestr = [cropname '_' nutrient '_ver' verno ];
            appratemap = DataStoreGateway([titlestr '_rate']);
            datatypemap = DataStoreGateway([titlestr '_datatype']);
            areamap = DataStoreGateway([titlestr '_area']);
            areahamap = areamap .* gridcellareas;
            
            ctries_wodata = {};
            ctries_withdata = {};
            ctries_nocrop = {};
            
            % loop through all ctries to find out if they are missing data (-9)
            disp(['Finding countries missing data for ' cropname]);
            for k = 1:length(countrycodes)
                
                ratelist = [];
                
                countrycode = countrycodes{k};
                outline = CountryCodetoOutline(countrycode);
                
                ratetemp = appratemap .* outline;
                ratetemp = ratetemp(CropMaskIndices);
                ratetemp = ratetemp(~isnan(ratetemp));
                uniquerates = unique(ratetemp);
                tmp = find(uniquerates == 0);
                uniquerates(tmp) = [];
                
                if uniquerates == -9;
                    % it is ... let's add it to missing data list
                    ctries_wodata{end+1} = countrycode;
                else
                    if isempty(uniquerates)
                        ctries_nocrop{end+1} = countrycode;
                    else
                        ctries_withdata{end+1} = countrycode;
                    end
                end
            end
            
            % find area-weighted average application rates for the globe and
            % for each economic group, using only the points for which we have
            % subnational or national-level application rate data
            
            % get the global average
            
            ii = find(appratemap > 0);
            tmp = appratemap(ii) .* areamap(ii) .* gridcellareas(ii);
            tmp = mean(tmp);
            meanarea = mean(areamap(ii) .* gridcellareas(ii));
            globalavg = tmp ./ meanarea;
            
            % get the income-specific averages
            
            uniqueincomes = {};
            for i = 1:length(ctries_withdata)
                datactry = ctries_withdata{i};
                tmp = WBIhtable.get(datactry);
                if ~isempty(tmp)
                    uniqueincomes = [uniqueincomes; tmp];
                end
            end
            uniqueincomes = unique(uniqueincomes);
            
            clear LIrate LIsimilarlist LMIrate LMIsimilarlist UMIrate ...
                UMIsimilarlist HIrate HIsimilarlist;
            
            for i = 1:length(uniqueincomes)
                incomelevel = uniqueincomes{i};
                
                ratelist = [];
                arealist = [];
                similar = {};
                
                for j = 1:length(ctries_withdata)
                    datactry = ctries_withdata{j};
                    tmp = WBIhtable.get(datactry);
                    
                    % if the income levels match, add to ratelist (and similar
                    % list)
                    if strmatch(incomelevel,tmp);
                        
                        similar{end+1} = datactry;
                        
                        outline = CountryCodetoOutline(datactry);
                        
                        ctry_appratemap = appratemap .* outline;
                        ii = find(isfinite(ctry_appratemap));
                        
                        tmp = ctry_appratemap(ii);
                        tmp2 = areahamap(ii);
                        
                        ii = find(tmp == -9);
                        tmp(ii) = [];
                        tmp2(ii) = [];
                        ii = find(tmp == 0);
                        tmp(ii) = [];
                        tmp2(ii) = [];
                        
                        ratelist = [ratelist(:)' tmp(:)'];
                        arealist = [arealist(:)' tmp2(:)'];
                        
                    end
                end
                
                if ~isempty(ratelist)
                    
                    % create an area-weighted average application rate using
                    % the rates from countries of this economic status
                    
                    tmp = ratelist(:) .* arealist(:);
                    tmp = mean(tmp);
                    meanarea = mean(arealist);
                    simctryrate = tmp ./ meanarea;
                    
                    % list the countries
                    similarlist = [];
                    for k = 1:length(similar);
                        tmp = similar{k};
                        similarlist = [similarlist '; ' tmp];
                    end
                    
                    % save the rate and the similar country list for the
                    % appropriate economic status
                    if strmatch(incomelevel, 'Low income')
                        LIrate = simctryrate;
                        LIsimilarlist = similarlist;
                    elseif strmatch(incomelevel, 'Lower middle income')
                        LMIrate = simctryrate;
                        LMIsimilarlist = similarlist;
                    elseif strmatch(incomelevel, 'Upper middle income')
                        UMIrate = simctryrate;
                        UMIsimilarlist = similarlist;
                    elseif strmatch(incomelevel, 'High income')
                        HIrate = simctryrate;
                        HIsimilarlist = similarlist;
                    end
                    
                else
                    warning(['Problem with filling data for ' incomelevel ...
                        '; data should be available but was not able to ' ...
                        'calculate an application rate'])
                end
                
            end
            
            % fill in the values for countries without data: use data from
            % similar economic groups if possible, otherwise use the global
            % average
            
            for k = 1:length(ctries_wodata);
                countrycode =  ctries_wodata{k};
                
                outline = CountryCodetoOutline(countrycode);
                ctry_appratemap = appratemap .* outline;
                ii = find(ctry_appratemap == -9);
                
                incomelevel = WBIhtable.get(countrycode);
                
                if ~isempty(incomelevel)
                    switch incomelevel
                        case 'Low income'
                            tmp = 'LI';
                            tmp2 = exist('LIrate');
                        case 'Lower middle income'
                            tmp = 'LMI';
                            tmp2 = exist('LMIrate');
                        case 'Upper middle income'
                            tmp = 'UMI';
                            tmp2 = exist('UMIrate');
                        case 'High income'
                            tmp = 'HI';
                            tmp2 = exist('HIrate');
                    end
                    
                    % if we have an average calculated for this income level,
                    % fill in the country data appropriately; otherwise, use
                    % the global average. record the accuracy of the average.
                    if tmp2 == 1;
                        % grab the similar countries list
                        eval(['similarlist = ' tmp 'similarlist;']);
                        disp(['Filling in ' cropname ' data for ' ...
                            countrycode ' with average application rate ' ...
                            'data from ' incomelevel ' countries: ' ...
                            similarlist]);
                        eval(['appratemap(ii) = ' tmp 'rate;']);
                        datatypemap(ii) = 5;
                    else
                        disp(['No similar countries for ' countrycode ...
                            '; using global average ' cropname ' data']);
                        appratemap(ii) = globalavg;
                        datatypemap(ii) = 5.5;
                    end
                    
                else % if no income level was found, use the global average
                    disp(['No income level for ' countrycode '; using ' ...
                        'global average ' cropname ' data']);
                    appratemap(ii) = globalavg;
                    datatypemap(ii) = 5.5;
                end
            end
            DataStoreGateway([titlestr '_rate'], appratemap);
            DataStoreGateway([titlestr '_datatype'], datatypemap);
        end
    end
    
    
    
    %% Scale using subnational data
    
    disp('Begin scaling application rate data using subnational data');
    
    % build a total consumption map; this is necessary for scaling purposes
    disp('Building a map of total nutrient consumption');
    total_consmap = zeros(4320,2160);
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
        crop_consmap = (areamap.*gridcellareas.*appratemap);
        total_consmap = total_consmap + crop_consmap;
    end
    
    % store this map for reference
    DataStoreGateway(['totalcons_' nutrient '_noscaling'], ...
        total_consmap);
    
    for snp = 1:2;
        if snp == 1;
            
            disp('Executing subnational scaling protocol number 1');
            
            scalingmap = ones(4320,2160);
            snudatamap = zeros(4320,2160);
            
            % loop through countries to find subnational data
            for c = 1:length(countrycodes)
                countrycode = countrycodes{c};
                
                % Find the rows with data for this country:
                ctryrows = row_htable.get(countrycode);
                
                % Create a list for ctryrows minus the data type row,
                % country data row, and data source row
                subnationalrows = ctryrows;
                subnationalrows([1, 2, 3]) = [];
                
                % Find the rows for data type, source, and the
                % country-level data
                tmp = strmatch('data type', inputfile.Name_1(ctryrows));
                datatyperow = ctryrows(tmp);
                
                eval(['datacol = inputfile.cons_' nutrient 'fert;']);
                compcol = inputfile.cons_compfert;
                
                datatype = str2double(datacol{datatyperow});
                country = inputfile.Cntry_name{datatyperow};
                
                if datatype > 1; % it can be -9 for no data, 2, or 2.5
                    
                    % calculate the number of snus with subnational data, the
                    % total amount of area in these snus, and the total amount
                    % of consumption in these snus.
                    
                    totfertsnus_num = 0;
                    totfertsnus_cons = 0;
                    totfertsnus_area = 0;
                    
                    for d = 1:length(subnationalrows);
                        snurow = subnationalrows(d);
                        nutrientdata = str2double(datacol{snurow});
                        compdata = str2double(compcol{snurow});
                        snucode = inputfile.Sage_admin{snurow};
                        
                        snu_cons_data = 0;
                        snudataflag = 0;
                        if ~isnan(nutrientdata)
                            snu_cons_data = snu_cons_data ...
                                + nutrientdata;
                            snudataflag = 1;
                            if ~isnan(compdata)
                                snu_cons_data = snu_cons_data ...
                                    + compdata;
                                snudataflag = 1;
                            end
                        end
                        
                        if snudataflag == 1;
                            
                            totfertsnus_num = totfertsnus_num + 1;
                            [outline, ii] = CountryCodetoOutline(snucode);
                            
                            % get area & add to the total fertilized area for
                            % all the snus with data
                            ii = find(isnan(totfertlandmap));
                            totfertlandmap(ii) = 0; % this shouldn't have NaNs
                            % unless pulled from DataStoreGateway
                            snuarea = sum(sum(totfertlandmap .* outline));
                            totfertsnus_area = totfertsnus_area + snuarea;
                            
                            % get consumption & add to total consumption for
                            % all the snus with data
                            if datatype == 2;
                                totfertsnus_cons = totfertsnus_cons + ...
                                    snu_cons_data;
                            elseif datatype == 2.5
                                % snu_cons_data is actually a rate if this
                                % is data type 2.5. convert to cons by
                                % multiplying by area.
                                totfertsnus_cons = totfertsnus_cons + ...
                                    (snu_cons_data .* snuarea);
                            end
                        end
                    end
                    
                    % find the area-weighted average consumption per ha of
                    % total fertilized land. This is calculated as
                    % (total consumption across all snus / # snus) / (sum
                    % of area over all snus / # snus). This is a
                    % simplification (see ppt slide or publication) of the
                    % full weighted average equation.
                    
                    wa_rate = (totfertsnus_cons ./ totfertsnus_num) ./ ...
                        (totfertsnus_area ./ totfertsnus_num);
                    
                    % now, loop through each SNU and calculate a scalar
                    % using the adjusted data in the datacol and the weighted
                    % average application rate. this scalar is
                    % (nutrient consumption in kg)
                    % cons / totfertarea
                    % build total consumption
                    
                    for d = 1:length(subnationalrows);
                        snurow = subnationalrows(d);
                        
                        snucode = inputfile.Sage_admin{snurow};
                        snuname1 = inputfile.Name_1{snurow};
                        snuname2 = inputfile.Name_2{snurow};
                        nutrientdata = str2double(datacol{snurow});
                        compdata = str2double(compcol{snurow});
                        snucode = inputfile.Sage_admin{snurow};
                        
                        snu_cons_data = 0;
                        snudataflag = 0;
                        if ~isnan(nutrientdata)
                            snu_cons_data = snu_cons_data ...
                                + nutrientdata;
                            snudataflag = 1;
                            if ~isnan(compdata)
                                snu_cons_data = snu_cons_data ...
                                    + compdata;
                                snudataflag = 1;
                            end
                        end
                        
                        if snudataflag == 1;
                            
                            [outline, ii] = CountryCodetoOutline(snucode);
                            
                            if datatype == 2;
                                snurate = snu_cons_data ./ ...
                                    sum(sum(totfertlandmap .* outline));
                            elseif datatype == 2.5
                                snurate = snu_cons_data;
                            end
                            
                            scalar = snurate ./ wa_rate;
                            
                            if scalar > 1.5
                                scalar = 1.5;
                                disp(['Scalar for ' nutrient ' ' country...
                                    ': ' snuname1 ' ' snuname2 ...
                                    ' is > 1.5 (' num2str(scalar) ...
                                    ') - limiting scalar to 1.5']);
                            elseif scalar < 0.5
                                scalar = 0.5;
                                disp(['Scalar for ' nutrient ' ' country...
                                    ': ' snuname1 ' ' snuname2 ...
                                    ' is < 0.5 (' num2str(scalar) ...
                                    ') - limiting scalar to 0.5']);
                            end
                            
                            scalingmap(ii) = scalar;
                            snudatamap(ii) = 1;
                            
                            disp(['Scaling ' nutrient ' consumption ' ...
                                'with subnational data from ' country ...
                                ': ' snuname1 ' ' snuname2 ...
                                '; scalar = ' num2str(scalar)]);
                            
                        else
                            
                            disp(['No subnational ' nutrient ' data ' ...
                                'to use as a scalar for ' country ...
                                ': ' snuname1 ' ' snuname2]);
                            
                        end
                    end
                end
            end
            
            % loop through crops and scale the data using the scalingmap,
            % calculate a crop-specific correction factor for each country,
            % so that the weighted average application rate is equal pre-
            % and post-scaling (aka equal consumption)
            
            total_consmap_scaled = zeros(4320,2160);
            
            for c = 1:length(croplist)
                cropname = croplist{c};
                
                titlestr = [cropname '_' nutrient '_ver' verno ];
                appratemap = DataStoreGateway([titlestr '_rate']);
                kk = find(isfinite(appratemap));
                areamap = DataStoreGateway([titlestr '_area']);
                areahamap = areamap .* gridcellareas;
                datatypemap = DataStoreGateway([titlestr '_datatype']);
                
                disp(['Calculating correction factors for ' cropname ...
                    ' scalar data']);
                crop_scalar_corrfact_map = ones(4320,2160);
                
                for d = 1:length(countrycodes);
                    countrycode = countrycodes{d};
                    
                    [outline, ii] = CountryCodetoOutline(countrycode);
                    
%                     tmp = mean(appratemap(kk) .* areahamap(kk) ...
%                         .* outline(kk)) ./ mean(areahamap(kk))
                    
                    tmp = sum(sum(appratemap(kk) .* areahamap(kk) ...
                        .* outline(kk)));
                    tmp2 = sum(sum(appratemap(kk) .* areahamap(kk) ...
                        .* outline(kk) .* scalingmap(kk)));
                    
                    if tmp > 0;
                        crop_scalar_corrfact = tmp ./ tmp2;
                        crop_scalar_corrfact_map(ii) = ...
                            crop_scalar_corrfact;
                    end
                end
                
                disp(['Applying subnational scalars to ' cropname ...
                    ' data']);
                
                appratemap = appratemap .* scalingmap .* ...
                    crop_scalar_corrfact_map;
                DataStoreGateway([titlestr '_rate_SNP1'], ...
                    appratemap);
                
                % save the data type appropriately
                
                % if we scaled subnational application rate data, call it
                % data type 0.5
                jj = find(snudatamap == 1 & datatypemap == 1);
                datatypemap(jj) = 0.5;
                % if we scaled national-level data, call it data type 2
                jj = find(snudatamap == 1 & datatypemap == 3);
                datatypemap(jj) = 2;
                % if we scaled national-level "other crop" data, call it
                % data type 3.25
                jj = find(snudatamap == 1 & datatypemap == 3.5);
                datatypemap(jj) = 3.25;
                % if we scaled extrapolated data from countries of similar
                % economic status, call it data type 4
                jj = find(snudatamap == 1 & datatypemap == 5);
                datatypemap(jj) = 4;
                % if we scaled extrapolated global avg application rate
                % data, call it data type 4.5
                jj = find(snudatamap == 1 & datatypemap == 5.5);
                datatypemap(jj) = 4.5;
                DataStoreGateway([titlestr '_datatype_SNP1'], ...
                    datatypemap);
                
                % calculate the total consumption map
                
                jj = find(appratemap < 0); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(isnan(appratemap)); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(areamap < 0); % put all no data and -9 values to zero
                areamap(jj) = 0;
                jj = find(isnan(areamap)); % put all no data and -9 values to zero
                areamap(jj) = 0;
                crop_consmap = (areamap.*gridcellareas.*appratemap);
                total_consmap_scaled = total_consmap_scaled + crop_consmap;
                
            end
            
            % save the scaling map
            DataStoreGateway('scalingmap_SNP1', scalingmap);
            
            % save the SNP1 scaled total consumption map;
            DataStoreGateway(['totalcons_' nutrient '_scaled_SNP1'], ...
                total_consmap_scaled);
            
            
            
            %% Match everything up with FAO consumption
            
            disp(['Begin scaling rate data to match with FAO ' ...
                'nutrient consumption data']);
            
            % save total_consmap_scaled as total_consmap in this
            % calculation. reset total_consmap_scaled - now that variable
            % will be used for a map that has been scaled to match FAO
            % consumption data
            
            total_consmap = total_consmap_scaled;
            total_consmap_scaled = zeros(4320,2160);
            
            % create a new scaling map
            scalingmap = ones(4320,2160);
            
            % create a binary fao data map; 1 = yes, we have FAO data, 0 =
            % no FAO data. I am doing this b/c some countries may perfectly
            % match up to FAO b/c they were already scaled with the
            % subnational data (if subnational consumption was normalized
            % to the FAO data)
            faodatamap = nan(4320,2160);
            
            % loop through countries and calculate consumption; compare to
            % FAO consumption
            
            for k = 1:length(countrycodes)
                
                countrycode = countrycodes{k};
                ctryrows = row_htable.get(countrycode);
                
                % get the country name
                tmp = strmatch('data type', inputfile.Name_1(ctryrows));
                datatyperow = ctryrows(tmp);
                country = inputfile.Cntry_name{datatyperow};
                [outline, ii] = CountryCodetoOutline(countrycode);
                
                % check if there are data rows in the FAO file for this
                % country
                ctryrows = strmatch(countrycode, faoinput.ctry_codes);
                
                if ~isempty(ctryrows)
                    % Find the row with the nutrient of interest:
                    tmp = strmatch(nutrient, faoinput.nutrient(ctryrows));
                    if ~isempty(tmp)
                        
                        datarow = ctryrows(tmp);
                        country_cons_fao = faoinput.avg_0203(datarow) ...
                            .* 1000;
                        country_cons_map = sum(sum(total_consmap ...
                            .* outline));
                        
                        if country_cons_map > 0;
                            
                            scalar = country_cons_fao ./ country_cons_map;
                            scalingmap(ii) = scalar;
                            faodatamap(ii) = 1;
                            disp(['Scalar for ' nutrient ' data in ' ...
                                country ' = ' num2str(scalar)]);
                            
                        else
                            
                            scalingmap(ii) = 0;
                            faodatamap(ii) = 0;
                            warning(['No map data for ' country '; ' ...
                                'check for problem with CropMaskIndices']);
                        end
                    else
                        disp(['No FAO ' nutrient ' entry for ' country]);
                        faodatamap(ii) = 0;
                    end
                    
                else
                    disp(['No FAO country entry for: ' country]);
                    faodatamap(ii) = 0;
                end
            end
            
            % save the scaling map
            DataStoreGateway('scalingmap_SNP1_FAO', scalingmap);
            
            % now loop through crops and apply the FAO scalars
            
            for c = 1:length(croplist)
                cropname = croplist{c};
                
                disp(['Applying FAO scalars to ' cropname ' data']);
                
                titlestr = [cropname '_' nutrient '_ver' verno ];
                appratemap = DataStoreGateway([titlestr '_rate_SNP1']);
                appratemap = appratemap .* scalingmap;
                DataStoreGateway([titlestr '_rate_SNP1_FAO'], ...
                    appratemap);
                
                % save the data type appropriately
                
                datatypemap = DataStoreGateway([titlestr ...
                    '_datatype_SNP1']);
                % all countries that have any fertilizer data of types
                % 1-4.5 are included in the FAO dataset (after some
                % checking by N. Mueller), so we only need to identify
                % whether extrapolated data for types 5 & 5.5 *do not*
                % have FAO data. These data types will be adjusted to 6
                % & 6.5. (6 = inferred from ctries of similar economic
                % status, not adjusted to match FAO. 6.5 = inferred
                % global avg application rate, not adjusted to match
                % FAO data.)
                jj = find(faodatamap == 0 & datatypemap == 5);
                datatypemap(jj) = 6;
                % set to zero for total consumption map
                appratemap(jj) = 0;
                jj = find(scalingmap == 0 & datatypemap == 5.5);
                datatypemap(jj) = 6.5;
                % set to zero for total consumption map
                appratemap(jj) = 0;
                DataStoreGateway([titlestr '_datatype_SNP1_FAO'], ...
                    datatypemap);
                
                % calculate the total consumption map
                
                areamap=DataStoreGateway([titlestr '_area']);
                jj = find(appratemap < 0); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(isnan(appratemap)); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(areamap < 0); % put all no data and -9 values to zero
                areamap(jj) = 0;
                jj = find(isnan(areamap)); % put all no data and -9 values to zero
                areamap(jj) = 0;
                crop_consmap = (areamap.*gridcellareas.*appratemap);
                total_consmap_scaled = total_consmap_scaled + crop_consmap;
             
            end
            
            % save the total consumption map
            
            total_consmap_scaled(faodatamap == 0) = 0;
            DataStoreGateway(['totalcons_' nutrient ...
                '_scaled_SNP1_FAO'], total_consmap_scaled);
            
            
            
        elseif snp == 2;
            disp('Executing subnational scaling protocol number 2');
            
            scalingmap = ones(4320,2160);
            snudatamap = zeros(4320,2160);
            
            % loop through countries to find subnational data
            for c = 1:length(countrycodes)
                countrycode = countrycodes{c};
                
                % Find the rows with data for this country:
                ctryrows = row_htable.get(countrycode);
                
                % Create a list for ctryrows minus the data type row,
                % country data row, and data source row
                subnationalrows = ctryrows;
                subnationalrows([1, 2, 3]) = [];
                
                % Find the rows for data type, source, and the
                % country-level data
                tmp = strmatch('data type', inputfile.Name_1(ctryrows));
                datatyperow = ctryrows(tmp);
                
                eval(['datacol = inputfile.cons_' nutrient 'fert;']);
                compcol = inputfile.cons_compfert;
                
                datatype = str2double(datacol{datatyperow});
                country = inputfile.Cntry_name{datatyperow};
                
                if datatype == 2.5
                    
                    % Data-type 2.5 is the average application rate over
                    % all crops in a given subnational unit. Multiply this
                    % by the total fertilized area to get the expected
                    % consumption and compare to the consumption on the
                    % map. NOTE: All entries for DT 2.5 are in units of N,
                    % P2O5, and K2O, so - at this time - THIS SECTION DOES
                    % NOT NORMALIZE TO FAO CONSUMPTION!! %%%%%%%%%%%%%%%%
                    
                    for d = 1:length(subnationalrows);
                        snurow = subnationalrows(d);
                        
                        snu_rate_data = str2double(datacol{snurow});
                        snucode = inputfile.Sage_admin{snurow};
                        snuname1 = inputfile.Name_1{snurow};
                        snuname2 = inputfile.Name_2{snurow};
                        
                        if ~isnan(snu_rate_data)
                            
                            [outline, ii] = CountryCodetoOutline(snucode);
                            
                            snu_total_consmap = total_consmap .* outline;
                            snu_cons_map = sum(sum(snu_total_consmap));
                            
                            snu_cons_data = snu_rate_data .* ...
                                sum(sum(totfertlandmap .* outline));
                            
                            scalar = snu_cons_data ./ snu_cons_map;
                            
                            if scalar > 1.5
                                scalar = 1.5;
                                disp(['Scalar for ' nutrient ' ' country...
                                    ': ' snuname1 ' ' snuname2 ...
                                    ' is > 1.5 (' num2str(scalar) ...
                                    ') - limiting scalar to 1.5']);
                            elseif scalar < 0.5
                                scalar = 0.5;
                                disp(['Scalar for ' nutrient ' ' country...
                                    ': ' snuname1 ' ' snuname2 ...
                                    ' is < 0.5 (' num2str(scalar) ...
                                    ') - limiting scalar to 0.5']);
                            end
                            
                            scalingmap(ii) = scalar;
                            snudatamap(ii) = 1;
                            
                            disp(['Scaling ' nutrient ' consumption ' ...
                                'with subnational data from ' country ...
                                ': ' snuname1 ' ' snuname2 ...
                                '; scalar = ' num2str(scalar)]);
                            
                        else
                            
                            disp(['No subnational ' nutrient ' data ' ...
                                'to use as a scalar for ' country ...
                                ': ' snuname1 ' ' snuname2]);
                            
                        end
                    end
                end
                
                if datatype == 2;
                    
                    if strmatch(countrycode, 'USA');
                        
                        % For the USA, we do not have subnational data for
                        % all units, so we cannot normalize to FAO totals.
                        % However, since these data are already in N, P2O5,
                        % and K2O, there is no need to normalize.
                        
                        disp(['Skipping USA: cannot normalize US ' ...
                            nutrient ' data to FAO total consumption']);
                        
                    else
                        
                        % For all other countries, add up the total
                        % consumption for the nutrient specified + compound
                        % fertilizer. Then divide this total by the amount
                        % of nutrient consumed in the country according to
                        % FAO. This will give an approximate % nutrient
                        % number for all fertilizers containing the
                        % nutrient of interest. Ex: 1300 kg of
                        % nitrogenous fertilizer and 1000 kg of compound
                        % fertilizer consumed in a country according to
                        % subnational data. 1600 kg of N are consumed in
                        % the country according to FAO. This means the
                        % average N content of N-containing fertilizer is
                        % (1600/2300) or 0.6957 percent.
                        
                        disp(['Normalizing ' country ' subnational ' ...
                            nutrient ' consumption data ' ...
                            'with FAO consumption']);
                        
                        countrycons = 0;
                        
                        for d = 1:length(subnationalrows);
                            snurow = subnationalrows(d);
                            
                            nutrientdata = str2double(datacol{snurow});
                            compdata = str2double(compcol{snurow});
                            
                            % check to make sure we have nutrient data
                            % (this will skip the capital district of
                            % Pakistan where we don't have any consumption
                            % data, for example)
                            if ~isnan(nutrientdata)
                                countrycons = countrycons + ...
                                    nutrientdata;
                                % check to make sure we have compound
                                % fertilizer data (not available for many
                                % countries)
                                if ~isnan(compdata)
                                    countrycons = countrycons + ...
                                        compdata;
                                end
                            end
                        end
                        
                        % find the FAO data for this country
                        
                        ctryrows = strmatch(countrycode, faoinput.ctry_codes);
                        country = faoinput.countries{ctryrows(1)};
                        % Find the row with the nutrient of interest:
                        tmp = strmatch(nutrient, faoinput.nutrient(ctryrows));
                        if tmp > 0
                            datarow = ctryrows(tmp);
                            FAOcons = faoinput.avg_0203(datarow);
                        end
                        
                        percent_nutrient = FAOcons .* 1000 ./ countrycons;
                        
                        % put corrected data in the datacol
                        for d = 1:length(subnationalrows);
                            snurow = subnationalrows(d);
                            
                            nutrientdata = str2double(datacol{snurow});
                            compdata = str2double(compcol{snurow});
                            
                            adj_nutrientcons = 0;
                            snudataflag = 0;
                            if ~isnan(nutrientdata)
                                adj_nutrientcons = adj_nutrientcons ...
                                    + nutrientdata;
                                snudataflag = 1;
                                if ~isnan(compdata)
                                    adj_nutrientcons = adj_nutrientcons ...
                                        + compdata;
                                    snudataflag = 1;
                                end
                            end
                            
                            if snudataflag == 1;
                                adj_nutrientcons = adj_nutrientcons .* ...
                                    percent_nutrient;
                                datacol{snurow} = ...
                                    num2str(adj_nutrientcons);
                            end
                        end
                    end
                    
                    % now, loop through each SNU and calculate a scalar
                    % using the adjusted data in the datacol
                    % (nutrient consumption in kg)
                    
                    for d = 1:length(subnationalrows);
                        snurow = subnationalrows(d);
                        
                        snu_cons_data = str2double(datacol{snurow});
                        snucode = inputfile.Sage_admin{snurow};
                        snuname1 = inputfile.Name_1{snurow};
                        snuname2 = inputfile.Name_2{snurow};
                        
                        if ~isnan(snu_cons_data)
                            
                            [outline, ii] = CountryCodetoOutline(snucode);
                            
                            snu_total_consmap = total_consmap .* outline;
                            snu_cons_map = sum(sum(snu_total_consmap));
                            
                            scalar = snu_cons_data ./ snu_cons_map;
                            
                            if scalar > 1.5
                                scalar = 1.5;
                                disp(['Scalar for ' nutrient ' ' country...
                                    ': ' snuname1 ' ' snuname2 ...
                                    ' is > 1.5 (' num2str(scalar) ...
                                    ') - limiting scalar to 1.5']);
                            elseif scalar < 0.5
                                scalar = 0.5;
                                disp(['Scalar for ' nutrient ' ' country...
                                    ': ' snuname1 ' ' snuname2 ...
                                    ' is < 0.5 (' num2str(scalar) ...
                                    ') - limiting scalar to 0.5']);
                            end
                            
                            scalingmap(ii) = scalar;
                            snudatamap(ii) = 1;
                            
                            disp(['Scaling ' nutrient ' consumption ' ...
                                'with subnational data from ' country ...
                                ': ' snuname1 ' ' snuname2 ...
                                '; scalar = ' num2str(scalar)]);
                            
                        else
                            
                            disp(['No subnational ' nutrient ' data ' ...
                                'to use as a scalar for ' country ...
                                ': ' snuname1 ' ' snuname2]);
                            
                        end
                    end
                end
            end
            
            % loop through crops and scale the data using the scalingmap;
            % save a scaled version of the total consumption map
            
            total_consmap_scaled = zeros(4320,2160);
            
            for c = 1:length(croplist)
                cropname = croplist{c};
                
                disp(['Applying subnational scalars to ' cropname ...
                    ' data']);
                
                titlestr = [cropname '_' nutrient '_ver' verno ];
                appratemap = DataStoreGateway([titlestr '_rate']);
                appratemap = appratemap .* scalingmap;
                DataStoreGateway([titlestr '_rate_SNP2'], ...
                    appratemap);
                
                % save the data type appropriately
                
                datatypemap = DataStoreGateway([titlestr '_datatype']);
                % if we scaled subnational application rate data, call it
                % data type 0.5
                jj = find(snudatamap == 1 & datatypemap == 1);
                datatypemap(jj) = 0.5;
                % if we scaled national-level data, call it data type 2
                jj = find(snudatamap == 1 & datatypemap == 3);
                datatypemap(jj) = 2;
                % if we scaled extrapolated data from countries of similar
                % economic status, call it data type 4
                jj = find(snudatamap == 1 & datatypemap == 5);
                datatypemap(jj) = 4;
                % if we scaled extrapolated global avg application rate
                % data, call it data type 4.5
                jj = find(snudatamap == 1 & datatypemap == 5.5);
                datatypemap(jj) = 4.5;
                DataStoreGateway([titlestr '_datatype_SNP2'], ...
                    datatypemap);
                
                % calculate the total consumption map
                
                areamap=DataStoreGateway([titlestr '_area']);
                jj = find(appratemap < 0); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(isnan(appratemap)); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(areamap < 0); % put all no data and -9 values to zero
                areamap(jj) = 0;
                jj = find(isnan(areamap)); % put all no data and -9 values to zero
                areamap(jj) = 0;
                crop_consmap = (areamap.*gridcellareas.*appratemap);
                total_consmap_scaled = total_consmap_scaled + crop_consmap;
                
            end
            
            % save the scaling map
            DataStoreGateway('scalingmap_SNP2', scalingmap);
            
            % save the SNP2 scaled total consumption map;
            DataStoreGateway(['totalcons_' nutrient '_scaled_SNP2'], ...
                total_consmap_scaled);
            
            
            %% Match everything up with FAO consumption
            
            disp(['Begin scaling rate data to match with FAO ' ...
                'nutrient consumption data']);
            
            % save total_consmap_scaled as total_consmap in this
            % calculation. reset total_consmap_scaled - now that variable
            % will be used for a map that has been scaled to match FAO
            % consumption data
            
            total_consmap = total_consmap_scaled;
            total_consmap_scaled = zeros(4320,2160);
            
            % create a new scaling map
            scalingmap = ones(4320,2160);
            
            % create a binary fao data map; 1 = yes, we have FAO data, 0 =
            % no FAO data. I am doing this b/c some countries may perfectly
            % match up to FAO b/c they were already scaled with the
            % subnational data (if subnational consumption was normalized
            % to the FAO data)
            faodatamap = nan(4320,2160);
            
            % loop through countries and calculate consumption; compare to
            % FAO consumption
            
            for k = 1:length(countrycodes)
                
                countrycode = countrycodes{k};
                ctryrows = row_htable.get(countrycode);
                
                % get the country name
                tmp = strmatch('data type', inputfile.Name_1(ctryrows));
                datatyperow = ctryrows(tmp);
                country = inputfile.Cntry_name{datatyperow};
                [outline, ii] = CountryCodetoOutline(countrycode);
                
                % check if there are data rows in the FAO file for this
                % country
                ctryrows = strmatch(countrycode, faoinput.ctry_codes);
                
                if ~isempty(ctryrows)
                    % Find the row with the nutrient of interest:
                    tmp = strmatch(nutrient, faoinput.nutrient(ctryrows));
                    if ~isempty(tmp)
                        
                        datarow = ctryrows(tmp);
                        country_cons_fao = faoinput.avg_0203(datarow) ...
                            .* 1000;
                        country_cons_map = sum(sum(total_consmap ...
                            .* outline));
                        
                        if country_cons_map > 0;
                            
                            scalar = country_cons_fao ./ country_cons_map;
                            scalingmap(ii) = scalar;
                            faodatamap(ii) = 1;
                            disp(['Scalar for ' nutrient ' data in ' ...
                                country ' = ' num2str(scalar)]);
                            
                        else
                            
                            scalingmap(ii) = 0;
                            faodatamap(ii) = 0;
                            warning(['No map data for ' country '; ' ...
                                'check for problem with CropMaskIndices']);
                        end
                    else
                        disp(['No FAO ' nutrient ' entry for ' country]);
                        faodatamap(ii) = 0;
                    end
                    
                else
                    disp(['No FAO country entry for: ' country]);
                    faodatamap(ii) = 0;
                end
            end
            
            % save the scaling map
            DataStoreGateway('scalingmap_SNP2_FAO', scalingmap);
            
            % now loop through crops and apply the FAO scalars
            
            for c = 1:length(croplist)
                cropname = croplist{c};
                
                disp(['Applying FAO scalars to ' cropname ' data']);
                
                titlestr = [cropname '_' nutrient '_ver' verno ];
                appratemap = DataStoreGateway([titlestr '_rate_SNP2']);
                appratemap = appratemap .* scalingmap;
                DataStoreGateway([titlestr '_rate_SNP2_FAO'], ...
                    appratemap);
                
                % save the data type appropriately
                
                datatypemap = DataStoreGateway([titlestr ...
                    '_datatype_SNP2']);
                % all countries that have any fertilizer data of types
                % 1-4.5 are included in the FAO dataset (after some
                % checking by N. Mueller), so we only need to identify
                % whether extrapolated data for types 5 & 5.5 *do not*
                % have FAO data. These data types will be adjusted to 6
                % & 6.5. (6 = inferred from ctries of similar economic
                % status, not adjusted to match FAO. 6.5 = inferred
                % global avg application rate, not adjusted to match
                % FAO data.)
                jj = find(faodatamap == 0 & datatypemap == 5);
                datatypemap(jj) = 6;
                % set to zero for total consumption map
                appratemap(jj) = 0;
                jj = find(scalingmap == 0 & datatypemap == 5.5);
                datatypemap(jj) = 6.5;
                % set to zero for total consumption map
                appratemap(jj) = 0;
                DataStoreGateway([titlestr '_datatype_SNP2_FAO'], ...
                    datatypemap);
                
                % calculate the total consumption map
                
                areamap=DataStoreGateway([titlestr '_area']);
                jj = find(appratemap < 0); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(isnan(appratemap)); % put all no data and -9 values to zero
                appratemap(jj) = 0;
                jj = find(areamap < 0); % put all no data and -9 values to zero
                areamap(jj) = 0;
                jj = find(isnan(areamap)); % put all no data and -9 values to zero
                areamap(jj) = 0;
                crop_consmap = (areamap.*gridcellareas.*appratemap);
                total_consmap_scaled = total_consmap_scaled + crop_consmap;
                
                   
            end
            
            % save the total consumption map
            total_consmap_scaled(faodatamap == 0) = 0;
            DataStoreGateway(['totalcons_' nutrient ...
                '_scaled_SNP2_FAO'], total_consmap_scaled);
        
        end
    end
end

toc;
diary off



%%%%%% THIS IS TO SCALE PASTURE AREAS DOWN BASED ON THE  IFA DATA ... WE
%%%%%% DECIDED TO JUST SCALE THE APPLICATION RATES DOWN AND LEAVE THE
%%%%%% PASTURE AREA AS THE RAMANKUTTY ET AL. MAP

%     if strmatch(cropname, 'past2000') % NOTE: b/c the amounts of fertilized
%         % pasture are often far lower than actual pasture area, we
%         % scale each country's pasture map down so that the total area is
%         % equivalent to the IFA/FAO/IFDC statistic on how much pasture land
%         % was fertilized in a given country.
%         dataentry = 'pasture';
%         nutrient = 'N'; % NOTE: b/c the areas fertilized for each crop in
%         % IFA/FAO/IFDC database are the same for each nutrient, I can get
%         % away with just looking at the pasture areas for nitrogen.
%         m3pastmap = areahamap;
%         ii = find(isnan(m3pastmap));
%         m3pastmap(ii) = 0;
%         areahamap = zeros(4320,2160);
%         for c = 1:length(countrycodes);
%             ccode = countrycodes{c};
%             areaheader = [dataentry '_' nutrient '_areafert'];
%             eval(['areacol = inputfile.' areaheader ';']);
%             ctryrows = row_htable.get(ccode);
%             tmp = strmatch('country data', inputfile.Name_1(ctryrows));
%             countrydatarow = ctryrows(tmp);
%             IFApastarea = str2double(areacol{countrydatarow});
%             if IFApastarea > 0
%                 [outline] = CountryCodetoOutline(ccode);
%                 m3pastarea = sum(sum(m3pastmap.*outline));
%                 scalar = IFApastarea ./ m3pastarea;
%                 tmp = m3pastmap .* outline .* scalar;
%                 areahamap = areahamap + tmp;
%                 if isnan(sum(sum(areahamap)))
%                     disp('problem')
%                 end
%             end
%         end
%         disp('Saving adjusted pasture area map');
%         DataStoreGateway('m3pastmap_ha', areahamap);
%     end

