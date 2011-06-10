% fertilizermaps.m
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
%
% Version 2.0 - 1.20.2011 - Final version of the fertilizer data for the m3
% yield model paper. Added new procedures for scaling trusted and untrusted
% crops.



%% record preferences
verno = '2_25_3';
untrustedcropscalingmax = 2;
allcropsscalingmax = 2;
trustedcroptofaoratiomax = .95;
snscalarmax = 1.25;
snscalarmin = 0.75;


%% initialize diary and time record

ds = datestr(now);
diaryfilename = ['fertrunoutput v' verno ' ' ds '.txt'];
diary(diaryfilename);
disp(diaryfilename);
tic;
disp(['You are running version ' verno ' of fertilizermaps'])
disp(['Maximum scaling for untrusted crops = ' ...
    num2str(untrustedcropscalingmax) ' (if the untrusted crop scalar ' ...
    'is greater than this number, all crops will be scaled up ' ...
    'to match FAO consumption)']);
disp(['Maximum ratio of trusted crop consumption to FAO consumption = ' ...
    num2str(trustedcroptofaoratiomax) ' (any ratio larger than this ' ...
    'will trigger the code to scale both trusted and untrusted crops ' ...
    'to match FAO consumption)']);
disp(['Maximum scaling for all crops to match FAO = ' ...
    num2str(untrustedcropscalingmax)]);
disp(['Maximum subnational scalar = ' num2str(snscalarmax) ', minimum' ...
    ' subnational scalar = ' num2str(snscalarmin)]);



%% read input files

% load fertilizer data file
inputfile = ReadGenericCSV('subnationalfert6.csv');
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
path = [iddstring 'misc/area_ha_5min.nc'];
[DS] = OpenNetCDF(path);
gridcellareas = DS.Data;



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



%% build total fertilized land map and initialize data files
disp('Building total fertilized land map');
totfertlandmap = zeros(4320,2160);
for i = 1:length(croplist);
    cropname = croplist{i};
    disp(['Initializing files for ' cropname]);
    x = ([cropname '_5min.nc']);
    path = [iddstring 'Crops2000/crops/' x];
    [DS] = OpenNetCDF(path);
    areamap = DS.Data(:,:,1);
    jj = find(areamap>1e20);
    areamap(jj) = NaN;
    ii = find(areamap < 2 & areamap > 0 & (areamap .* gridcellareas) > ...
        0.0001); % must be at least a square meter of cropland!
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
                
                % save the data type: **NOTE** for all countries except the
                % US we are dealing with national-level data so this is
                % hard-coded as data type 3. For the US we will use data
                % type 1 so that we can use subnational wheat app rates
                % where we have them.
                if strmatch(countrycode, 'USA');
                    datacol{datatyperow} = '1';
                    areacol{datatyperow} = '1';
                else
                    datacol{datatyperow} = '3';
                    areacol{datatyperow} = '3';
                end
                
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
tmp = datalist([1:9 13:150 154]);
datalist = tmp;
tmp = proxylist([1:9 13:150 154]);
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
                                        datatypemap(ii) = 3;
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
    
    
    %% Fill gaps in application rate data with income-based extrapolation
    
    disp(['Begin filling application rate gaps from countries ' ...
        ' of similar economic status']);
    
    path = [iddstring 'misc/wbiclass.csv'];
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
    
    
    %% Match everything up with FAO consumption (first pass)
    
    disp(['Begin scaling rate data to match with FAO ' ...
        'nutrient consumption data']);
    
    % build total consumption maps: one for trusted crops (tcm_tc) and one
    % for "untrusted" (extrapolated) crops (tcm_utc)
    disp('Building a map of total nutrient consumption');
    tcm_tc = zeros(4320,2160);
    tcm_utc = zeros(4320,2160);
    for c = 1:length(croplist)
        cropname = croplist{c};
        titlestr = [cropname '_' nutrient '_ver' verno ];
        appratemap=DataStoreGateway([titlestr '_rate']);
        areamap=DataStoreGateway([titlestr '_area']);
        datatypemap = DataStoreGateway([titlestr '_datatype']);
        jj = find(appratemap < 0); % put no data and -9 values to zero
        appratemap(jj) = 0;
        jj = find(isnan(appratemap)); % put no data and -9 values to zero
        appratemap(jj) = 0;
        jj = find(areamap < 0); % put no data and -9 values to zero
        areamap(jj) = 0;
        jj = find(isnan(areamap)); % put no data and -9 values to zero
        areamap(jj) = 0;
        
        crop_consmap = (areamap.*gridcellareas.*appratemap);
        ii = find(datatypemap < 3.01);
        tcm_tc(ii) = tcm_tc(ii) + crop_consmap(ii);
        ii = find(datatypemap > 3.01);
        tcm_utc(ii) = tcm_utc(ii) + crop_consmap(ii);
    end
    
    tcm_allcrops = tcm_utc + tcm_tc;
    
    % store these maps for reference
    DataStoreGateway(['tcm_utc_' nutrient '_ver' verno ...
        '_noscaling'], tcm_utc);
    DataStoreGateway(['tcm_tc_' nutrient '_ver' verno ...
        '_noscaling'], tcm_tc);
    DataStoreGateway(['tcm_allcrops_' nutrient '_ver' verno ...
        '_noscaling'],tcm_allcrops);
    
    % create scaling maps: one for trusted crops (scalingmap_tc) and one
    % for "untrusted" (extrapolated) crops (scalingmap_utc)
    scalingmap_tc = ones(4320,2160);
    scalingmap_utc = ones(4320,2160);
    
    % create a binary fao data map; 1 = yes, we have FAO data, 0 =
    % no FAO data. also create a "faoscalarmaxmap" to indicate which
    % countries will not match the FAO data b/c they will max out.
    faodatamap = nan(4320,2160);
    faoscalarmaxmap = zeros(4320,2160);
    
    % loop through countries and calculate consumption; compare to
    % FAO consumption
    
    for k = 1:length(countrycodes)
        
        countrycode = countrycodes{k};
        ctryrows = row_htable.get(countrycode);
        scaleeverythingflag = 0;
        
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
                country_cons_fao = faoinput.avg_9703(datarow) .* 1000;
                country_cons_utc = sum(sum(tcm_utc .* outline));
                country_cons_tc = sum(sum(tcm_tc .* outline));
                
                % perform a sanity check - we should have some data on
                % untrusted crops from our map
                if country_cons_utc > 0;
                    
                    scalar_utc = (country_cons_fao - country_cons_tc) ...
                        ./ country_cons_utc;
                    
                    % if the scalar exceeds the untrustedcropscalingmax
                    % then we decide we have little faith in our "trusted
                    % crops". we will scale up all the data for this
                    % country, including crops for which we had an
                    % application rate. otherwise, use the scalar_utc for
                    % the scalingmap_utc.
                    if scalar_utc > untrustedcropscalingmax
                        disp(['The scalar for untrusted crops ' ...
                            'exceeds ' num2str(untrustedcropscalingmax)...
                            ' in ' country ' (scalar = ' ...
                            num2str(scalar_utc) ')']);
                        scaleeverythingflag = 1;
                    end
                    % if our trusted crop consumption exceeds or almost
                    % exceeds the FAO consumption then scale everything.
                    if (country_cons_tc ./ country_cons_fao) > ...
                            trustedcroptofaoratiomax;
                        tmp = (country_cons_tc ./ country_cons_fao);
                        disp(['Trusted crop consumption exceeds or '...
                            ' nearly exceeds (> ' ...
                            num2str(trustedcroptofaoratiomax) ...
                            ') FAO consumption ' ...
                            ' in ' country '. Ratio of trusted crop '...
                            'consumption to FAO consumption = ' ...
                            num2str(tmp)]);
                        scaleeverythingflag = 1;
                    end
                    
                    % calculate a scalar using all crops if the flag is on
                    if scaleeverythingflag == 1
                        disp('Scaling all crop data to match FAO.');
                        scalar = country_cons_fao ./ (country_cons_utc ...
                            + country_cons_tc);
                        % if the scalar exceeds the allcropsscalingmax,
                        % adjust it downward to the max allowable scalar
                        if scalar > allcropsscalingmax
                            disp(['Scalar for ' nutrient ' all crop ' ...
                                'data in ' country ' (' num2str(scalar) ...
                                ') exceeds max allowable, will be adjusted' ...
                                ' to ' num2str(allcropsscalingmax)]);
                            scalar = allcropsscalingmax;
                            faoscalarmaxmap(ii) = 1;
                        else
                            disp(['Scalar for ' nutrient ' all crop ' ...
                                'data in ' country ' = ' num2str(scalar)]);
                        end
                        scalingmap_tc(ii) = scalar;
                        scalingmap_utc(ii) = scalar;
                    else
                        scalingmap_utc(ii) = scalar_utc;
                        disp(['Scalar for ' nutrient ' untrusted crop ' ...
                            'data in ' country ' = ' num2str(scalar_utc)]);
                    end
                    faodatamap(ii) = 1;
                    
                else
                    
                    scalingmap_utc(ii) = 0;
                    faodatamap(ii) = 0;
                    disp(['No map data for ' country '; ' ...
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
    
    %     clear tcm_tc tcm_utc tcm_allcrops
    
    % save the scaling maps
    
    DataStoreGateway(['scalingmap_tc_' nutrient '_FAO'], scalingmap_tc);
    DataStoreGateway(['scalingmap_utc_' nutrient '_FAO'], scalingmap_utc);
    
    % Now loop through crops and apply the FAO scalars. While doing this,
    % also calculate tcm_sn (total consumption map: subnational application
    % rate data) and tcm_n ((total consumption map: national application
    % rate data). We will use these maps to only scale national level
    % application rate data using subnational consumption data.
    
    tcm_sn = zeros(4320,2160);
    tcm_n = zeros(4320,2160);
    
    for c = 1:length(croplist)
        cropname = croplist{c};
        
        disp(['Applying FAO scalars to ' cropname ' data']);
        
        titlestr = [cropname '_' nutrient '_ver' verno ];
        appratemap = DataStoreGateway([titlestr '_rate']);
        datatypemap = DataStoreGateway([titlestr '_datatype']);
        ii = find(datatypemap < 3.01);
        appratemap(ii) = appratemap(ii) .* scalingmap_tc(ii);
        ii = find(datatypemap > 3.01);
        appratemap(ii) = appratemap(ii) .* scalingmap_utc(ii);
        DataStoreGateway([titlestr '_rate_FAO'], appratemap);
        
        % save the data type appropriately:
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
        jj = find(faodatamap == 0 & datatypemap == 5.5);
        datatypemap(jj) = 6.5;
        % set to zero for total consumption map
        DataStoreGateway([titlestr '_datatype_FAO'], datatypemap);
        
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
        ii = find(datatypemap == 1);
        tcm_sn(ii) = tcm_sn(ii) + crop_consmap(ii);
        ii = find(datatypemap > 1);
        tcm_n(ii) = tcm_n(ii) + crop_consmap(ii);
    end
    
    clear scalingmap_tc scalingmap_utc
    
    
    %% Scale using subnational data (protocol 2)
    
    disp('Begin scaling application rate data using subnational data');
    
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
                    
                    snu_cons_data = snu_rate_data .* ...
                        sum(sum(totfertlandmap .* outline));
                    
                    [outline, ii] = CountryCodetoOutline(snucode);
                    
                    snu_cons_sn = sum(sum(tcm_sn .* outline));
                    snu_cons_n = sum(sum(tcm_n .* outline));
                    
                    % now the scalar is only for national-level data (we
                    % choose to trust a subnational application rate over
                    % all else)
                    scalar = (snu_cons_data - snu_cons_sn) ./ snu_cons_n;
                    
                    % limit scalar to snscalingmin/max
                    
                    if scalar > snscalarmax
                        scalar = snscalarmax;
                        disp(['Scalar for ' nutrient ' ' country...
                            ': ' snuname1 ' ' snuname2 ' is > ' ...
                            num2str(snscalarmax) ' (' num2str(scalar) ...
                            ') - limiting scalar to ' ...
                            num2str(snscalarmax)]);
                    elseif scalar < snscalarmin
                        scalar = snscalarmin;
                        disp(['Scalar for ' nutrient ' ' country...
                            ': ' snuname1 ' ' snuname2 ' is < ' ...
                            num2str(snscalarmin) ' (' num2str(scalar) ...
                            ') - limiting scalar to ' ...
                            num2str(snscalarmin)]);
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
                    FAOcons = faoinput.avg_9703(datarow);
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
                    
                    snu_cons_sn = sum(sum(tcm_sn .* outline));
                    snu_cons_n = sum(sum(tcm_n .* outline));
                    
                    % now the scalar is only for national-level data (we
                    % choose to trust a subnational application rate over
                    % all else)
                    scalar = (snu_cons_data - snu_cons_sn) ./ snu_cons_n;
                    
                    % for the provinces in Canada where we assume no
                    % fertilizer consumption (0) we end up with NaN - make
                    % this into 1
                    if isnan(scalar)
                        scalar = 1;
                    elseif snu_cons_data == 0
                        scalar = 1;
                    end
                    
                    % limit scalar to snscalingmin/max
                    
                    if scalar > snscalarmax
                        scalar = snscalarmax;
                        disp(['Scalar for ' nutrient ' ' country...
                            ': ' snuname1 ' ' snuname2 ' is > ' ...
                            num2str(snscalarmax) ' (' num2str(scalar) ...
                            ') - limiting scalar to ' ...
                            num2str(snscalarmax)]);
                    elseif scalar < snscalarmin
                        scalar = snscalarmin;
                        disp(['Scalar for ' nutrient ' ' country...
                            ': ' snuname1 ' ' snuname2 ' is < ' ...
                            num2str(snscalarmin) ' (' num2str(scalar) ...
                            ') - limiting scalar to ' ...
                            num2str(snscalarmin)]);
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
    
    tcm_allcrops_sncscaled = zeros(4320,2160);
    tcm_n_sncscaled = zeros(4320,2160);
    
    for c = 1:length(croplist)
        cropname = croplist{c};
        
        disp(['Applying subnational scalars to ' cropname ...
            ' data']);
        
        titlestr = [cropname '_' nutrient '_ver' verno ];
        appratemap = DataStoreGateway([titlestr '_rate_FAO']);
        datatypemap = DataStoreGateway([titlestr '_datatype_FAO']);
        
        % apply subnational consumption scalars only to national-level data
        ii = find(datatypemap > 1);
        appratemap(ii) = appratemap(ii) .* scalingmap(ii);
        DataStoreGateway([titlestr '_rate_FAO_SNS'], ...
            appratemap);
        
        % save the data type appropriately
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
        % now add .25 if the application rate was maxed out against the
        % faoscalingmax
        jj = find(faoscalarmaxmap == 1);
        datatypemap(jj) = datatypemap(jj) + .25;
        % save the datatypemap
        DataStoreGateway([titlestr '_datatype_FAO_SNS'], ...
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
        tcm_allcrops_sncscaled = tcm_allcrops_sncscaled + crop_consmap;
        tcm_n_sncscaled(ii) = tcm_n_sncscaled(ii) + crop_consmap(ii); % ii are
        % still the indices for national-level data (trusted and untrusted)
        
    end
    
    % save the scaling map
    DataStoreGateway(['scalingmap_' nutrient '_ver' verno '_FAO_SNS'], ...
        scalingmap);
    
    % save the SN scaled total consumption map;
    DataStoreGateway(['tcm_allcrops_' nutrient '_ver' verno '_FAO_SNS'],...
        tcm_allcrops_sncscaled);
    DataStoreGateway(['tcm_n_scaled_' nutrient '_ver' verno '_FAO_SNS'],...
        tcm_n_sncscaled);
    clear tcm_n
    
    
    %% Match everything up with FAO consumption
    
    disp(['Begin scaling rate data to match with FAO ' ...
        'nutrient consumption data']);
    
    % create a new scaling map and total consumption map
    scalingmap = ones(4320,2160);
    tcm_allcrops_final = zeros(4320,2160);
    
    % %     % create a binary fao data map; 1 = yes, we have FAO data, 0 =
    % %     % no FAO data. I am doing this b/c some countries may perfectly
    % %     % match up to FAO b/c they were already scaled with the
    % %     % subnational data (if subnational consumption was normalized
    % %     % to the FAO data)
    % %     faodatamap = nan(4320,2160);
    
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
        
        % check to see if this country maxed out on the initial scaling to
        % match FAO consumption. if so, we will not try to match the
        % consumption yet again.
        if sum(sum(faoscalarmaxmap .* outline)) > 0
            disp(['skipping adjustment of ' country ' ' nutrient ...
                ' data since we previously hit the scaling max when ' ...
                'attempting to normalize to FAO consumption.']);
        else
            
            % check if there are data rows in the FAO file for this
            % country
            ctryrows = strmatch(countrycode, faoinput.ctry_codes);
            
            if ~isempty(ctryrows)
                % Find the row with the nutrient of interest:
                tmp = strmatch(nutrient, faoinput.nutrient(ctryrows));
                if ~isempty(tmp)
                    
                    datarow = ctryrows(tmp);
                    country_cons_fao = faoinput.avg_9703(datarow) ...
                        .* 1000;
                    
                    [outline, ii] = CountryCodetoOutline(countrycode);
                    
                    country_cons_sn = sum(sum(tcm_sn .* outline));
                    country_cons_n = sum(sum(tcm_n_sncscaled .* outline));
                    
                    if country_cons_n > 0;
                        
                        % the scalar is only for national-level data (we
                        % choose to trust a subnational application rate
                        % over all else)
                        scalar = (country_cons_fao - country_cons_sn) ...
                            ./ country_cons_n;
                        scalingmap(ii) = scalar;
                        faodatamap(ii) = 1;
                        disp(['Final scalar for ' nutrient ...
                            ' national data '...
                            'in ' country ' = ' num2str(scalar)]);
                        
                    else
                        
                        scalingmap(ii) = 0;
                        faodatamap(ii) = 0;
                        disp(['No map data for ' country '; ' ...
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
    end
    
    % save the scaling map
    DataStoreGateway(['scalingmap_' nutrient '_ver' verno ...
        '_FAO_SNS_FINAL'], scalingmap);
    
    % now loop through crops and apply the FAO scalars
    
    for c = 1:length(croplist)
        cropname = croplist{c};
        
        disp(['Applying final FAO scalars to ' cropname ' data']);
        
        titlestr = [cropname '_' nutrient '_ver' verno ];
        appratemap = DataStoreGateway([titlestr '_rate_FAO_SNS']);
        datatypemap = DataStoreGateway([titlestr '_datatype_FAO_SNS']);
        ii = find(datatypemap > 1);
        appratemap(ii) = appratemap(ii) .* scalingmap(ii);
        DataStoreGateway([titlestr '_rate_FAO_SNS_FINAL'], appratemap);
        
        % calculate the total consumption map
        
        areamap = DataStoreGateway([titlestr '_area']);
        jj = find(appratemap < 0); % put no data and -9 values to zero
        appratemap(jj) = 0;
        jj = find(isnan(appratemap)); % put no data and -9 values to zero
        appratemap(jj) = 0;
        jj = find(areamap < 0); % put no data and -9 values to zero
        areamap(jj) = 0;
        jj = find(isnan(areamap)); % put no data and -9 values to zero
        areamap(jj) = 0;
        crop_consmap = (areamap.*gridcellareas.*appratemap);
        tcm_allcrops_final = tcm_allcrops_final + crop_consmap;
        
    end
    
    % save the total consumption map
    tcm_allcrops_final(faodatamap == 0) = NaN;
    DataStoreGateway(['tcm_allcrops_' nutrient '_ver' verno ...
        '_FAO_SNS_FINAL'], tcm_allcrops_final);
    
end

toc;
diary off



