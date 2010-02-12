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
verno = '1_5';
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


%% add hash table for inputfile

if ~exist('htable')
    htable = java.util.Properties;
    
    for j=1:length(countrycodes);
        ii=strmatch(countrycodes{j},inputfile.ctry_code)
        htable.put(countrycodes{j},ii);
    end
end




cropinput = ReadGenericCSV('proxylist.csv');
datalist = cropinput.datalist;
proxylist = cropinput.proxylist;
faoinput = ReadGenericCSV('FAO_0307avg.csv');

fao_ctries = unique(faoinput.ctry_codes);
fao_ctries = fao_ctries(2:length(fao_ctries)); % NOTE: DOING THIS B/C



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
%     for c = 1:length(croplist);
%         % in this section, start going through croplist.  for each crop,
%         % make an array with -9 where there is crop area.  will also save
%         % crop area in second level
%         
%         appratemap = nan(4320,2160);
%         cropname = croplist{c};
%         disp(['working on ' cropname]);
%         x = ([cropname '_5min.nc']);
%         path = [IoneDataDir 'Crops2000/crops/' x];
%         [DS] = OpenNetCDF(path);
%         tmp = DS.Data(:,:,1);
%         tmp(tmp > 100) = NaN;
%         ii = find(tmp < 2 & tmp > 0);
%         appratemap(ii) = -9; % put -9 where we know we have crop data ...
%         % but we do not know the application rate
%         tmp = DS.Data(:,:,1);
%         tmp(tmp > 2) = NaN;
%         appratemap(:,:,2) = tmp; % save M3 harvested area for this crop to
%         % the second level
%         appratemap=single(appratemap);
%         
%         
%         titlestr = [cropname '_' nutrient '_ver' verno];
%         DataStoreGateway([titlestr '_rate'],appratemap(:,:,1));
%         DataStoreGateway([titlestr '_area'],appratemap(:,:,2));
%     end
    
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
        for k = 1:length(fao_ctries)
            countrycode = fao_ctries{k};
            % Find the rows with data for this country:
            %%%BAD%%%          ctryrows = strmatch(countrycode, inputfile.ctry_code);
 
            ctryrows=htable.get(countrycode);
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
                            
                            filestr = [cropname '_' nutrient '_ver' verno '.nc'];
                            titlestr = [cropname '_' nutrient '_ver' verno ];
                            %%%%    DS = OpenNetCDF(filestr);
                            appratemap=DataStoreGateway([titlestr '_rate']);
                            
                            %%%%    appratemap = DS.Data(:,:,1);
                            
                            ii = find(appratemap > -10 & outline > 0);
                            appratemap(ii) = countrydata;
                            DataStoreGateway([titlestr '_rate'],appratemap);
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

    FillRateGaps
end

toc