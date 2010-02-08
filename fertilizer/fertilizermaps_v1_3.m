% fertilizermaps_v1_3.m
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

% Record the version number
verno = '1.3';
disp(['You are running version ' verno ' of fertilizermaps'])

tic

disp('Reading input CSV files')
% ReadGenericCSV.m converts a CSV file into a MATLAB structure where each
% column of the CSV file becomes an element of the structure.
%load fertinput;
% % % % inputfile = ReadGenericCSV('subnationalfert2.csv');
countrycodes = unique(inputfile.ctry_code);
tmp = strmatch('new',countrycodes); % remove any "new_snu" issues
countrycodes(tmp) = [];
cropinput = ReadGenericCSV('proxylist.csv');
datalist = cropinput.datalist;
proxylist = cropinput.proxylist;
faoinput = ReadGenericCSV('FAO_0307avg.csv');
disp('Reading input netCDF files')
SystemGlobals;
path = [IoneDataDir 'misc/area_ha_5min.nc'];
[DS] = OpenNetCDF(path);
gridcellareas = DS.Data;
path = [IoneDataDir 'AdminBoundary2005/Raster_NetCDF/3_M3lcover_5min/' ...
    'admincodes.csv'];
admincodes = ReadGenericCSV(path);
path = [IoneDataDir 'AdminBoundary2005/Raster_NetCDF/3_M3lcover_5min/' ...
    'admin_5min.nc'];
[DS] = OpenNetCDF(path);
AdminGrid = DS.Data;
load 5mincountries; % load 5min co_outlines for countries, plus the
% corresponding lookup tables - co_codes (country codes) and co_numbers,
% the corresponding numbers in the grid for each country

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

% move to output folder to begin writing files
str = ['output_v' verno];
mkdir(str);
cd(str);

for n = 1%%%%%%%%%%%%%%%%%%%%:3
    switch n
        case 1
            nutrient = 'N';
        case 2
            nutrient = 'P';
        case 3
            nutrient = 'K';
    end
    
    disp(['Begin working on nutrient: ' nutrient])
    
    % initialize fertilizer application maps for these crops: Level 1 =
    % fertilizer application rate data (here just -9s indicating that we
    % don't have data yet), Level 2 = Monfreda harvested area
    
    disp(['Initializing netcdf files for ' nutrient])
    for c = 1:length(croplist);
        appratemap = nan(4320,2160);
        cropname = croplist{c};
        disp(['working on ' cropname]);
        x = ([cropname '_5min.nc']);
        path = [IoneDataDir 'Crops2000/crops/' x];
        [DS] = OpenNetCDF(path);
        tmp = DS.Data(:,:,1);
        tmp(tmp > 100) = NaN;
        ii = find(tmp < 2 & tmp > 0);
        appratemap(ii) = -9; % put -9 where we know we have crop data ...
        % but we do not know the application rate
        tmp = DS.Data(:,:,1);
        tmp(tmp > 2) = NaN;
        appratemap(:,:,2) = tmp; % save M3 harvested area for this crop to
        % the second level
        clear DAS
        titlestr = [cropname '_' nutrient '_apprate_ver' verno];
        filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
        unitstr = ['tons/ha ' nutrient ' applied to ' cropname ' area'];
        DAS.units=unitstr;
        DAS.title=titlestr;
        DAS.missing_value=-9e10;
        DAS.underscoreFillValue=-9e10;
        WriteNetCDF(appratemap,titlestr,filestr,DAS,'Force');
    end
    
    % Loop through data list
    
    for datano = 1:length(datalist)
        dataentry = datalist{datano};
        
        disp(['Working on ' dataentry ' ' nutrient ' data'])
        
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
        
        % cycle through the countries
        for k = 1:length(countrycodes)
            countrycode = countrycodes{k};
            % Find the rows with data for this country:
            ctryrows = strmatch(countrycode, inputfile.ctry_code);
            % Create a list for ctryrows minus the data type row, country
            % data row, and data source row
            subnationalrows = ctryrows;
            subnationalrows([1, 2, 3]) = [];
            % Find the rows for data type, source, and the country-level
            % data
            tmp = strmatch('data type', inputfile.Name_1(ctryrows));
            datatyperow = ctryrows(tmp);
            tmp = strmatch('data source', inputfile.Name_1(ctryrows));
            datasourcerow = ctryrows(tmp);
            tmp = strmatch('country data', inputfile.Name_1(ctryrows));
            countrydatarow = ctryrows(tmp);
            
            datatype = str2double(datacol{datatyperow});
            datasource = datacol{datasourcerow};
            countrydata = str2double(datacol{countrydatarow});
            
            country = inputfile.Cntry_name{datatyperow};
            
            if (datatype > 0)
                
                switch datatype
                    
                    case 1
                        
                    case 2
                        
                    case 3
                        
                        
                        disp(['Processing country-level application ' ...
                            'rate data for ' dataentry ' in ' country])
                        
                        % Create a logical grid with ones where the country
                        % of interest is located
                        
                        ii = strmatch(countrycode, co_codes);
                        tmp = co_numbers(ii);
                        ii = find(co_outlines == tmp);
                        outline = zeros(4320,2160);
                        outline(ii) = 1;
                        
                        % now go through the proxy cell array and apply the
                        % application rate to each crop of interest
                        
                        %%%%%%%%%%%%% NEED TO FIGURE OUT HOW TO DO THIS FOR
                        %%%%%%%%%%%%% SPRING/WINTER WHEAT AND BARLEY ...
                        
                        for c = 1:length(proxycellarray);
                            cropname = proxycellarray{c};
                            
                            disp(['Applying application rate data to ' ...
                                'the ' cropname ' map']);
                            
                            filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
                            DS = OpenNetCDF(filestr);
                            appratemap = DS.Data(:,:,1);
                            ii = find(appratemap > -10 & outline > 0);
                            appratemap(ii) = countrydata;
                            DS.Data(:,:,1) = appratemap;
                            % write the netcdf again
                            titlestr = [cropname '_' nutrient '_apprate_ver' verno];
                            filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
                            WriteNetCDF(DS.Data,titlestr,filestr,DS,'Force');
                        end
                        
                    case 4
                        
                    case 5
                end
            else
                disp(['Not a valid data type for ' country])
            end
        end
    end
    
    % Now - need to get data from neighbors to fill in gaps
    % For each crop ... Find ctries with -9s ... then look for neighbors
    % with data
    
    disp('Begin filling application rate gaps from neighboring countries')
    for c = 1:length(croplist)
        cropname = croplist{c};
        disp(['Filling in data for ' cropname]);
        filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
        DS = OpenNetCDF(filestr);
        appratemap = DS.Data(:,:,1);
        ii = find(appratemap < -100);
        appratemap(ii) = NaN;
        
        for k = 1:length(countrycodes)
            countrycode = countrycodes{k};
            
            ii = strmatch(countrycode, co_codes);
            tmp = co_numbers(ii);
            ii = find(co_outlines == tmp);
            outline = zeros(4320,2160);
            outline(ii) = 1;
            
            uniquerates = unique(appratemap .* outline);
            tmp = find(uniquerates == 0);
            uniquerates(tmp) = [];
            
            if uniquerates == -9;
                 sagecountryname=StandardCountryNames(countrycode,'sage3','sagecountry')
                [NeighborCodesSage,NeighborNamesSage,AvgDistance] ...
                    = NearestNeighbor(countrycode);
                
                if ~isempty(NeighborCodesSage) % if there are neighbors
                    ratelist = [];
                    
                    for m = 1:length(NeighborCodesSage)
                        
                        neighborcode = NeighborCodesSage{m}
                        
                        ii = strmatch(neighborcode, co_codes);
                        tmp = co_numbers(ii);
                        ii = find(co_outlines == tmp);
                        outline = zeros(4320,2160);
                        outline(ii) = 1;
                        
                        ctry_appratemap = appratemap .* outline;
                        ii = find(isfinite(ctry_appratemap));
                        tmp = ctry_appratemap(ii);
                        
                        ii = find(tmp == -9);
                        tmp(ii) = [];
                        ii = find(tmp == 0);
                        tmp(ii) = [];
                        
                        ratelist = [ratelist tmp];
                        
                    end
                    
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
        
        appratemap = DS.Data(:,:,1);
        titlestr = [cropname '_' nutrient '_apprate_ver' verno];
        filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
        WriteNetCDF(DS.Data,titlestr,filestr,DS,'Force');

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
            filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
            DS = OpenNetCDF(filestr);
            
            jj = find(DS.Data < 0); % put all no data and -9 values to zero
            DS.Data(jj) = 0;
            jj = find(isnan(DS.Data)); % put all no data and -9 values to zero
            DS.Data(jj) = 0;
            crop_consmap = (DS.Data(:,:,1) .* DS.Data(:,:,2) .* outline);
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
        DS = OpenNetCDF(filestr);
        appratemap = DS.Data(:,:,1);
        ii = find(appratemap < -100);
        appratemap(ii) = NaN;
        appratemap = appratemap .* scalingmap;
        DS.Data(:,:,1) = appratemap;
        DS.Data(:,:,3) = scalingmap; % save the scaling map to level 3 for
        % reference purposes
        titlestr = [cropname '_' nutrient '_apprate_ver' verno];
        filestr = [cropname '_' nutrient '_apprate_ver' verno '.nc'];
        WriteNetCDF(DS.Data,titlestr,filestr,DS,'Force');
        
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
    
end

toc