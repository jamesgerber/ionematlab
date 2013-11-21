function ConstructRainfedCropMaps(IPvec,politunitflag, DataYear, ...
    excludestrangedatatypesflag)
%  CONSTRUCTRAINFEDCROPMAPS
%
% politunitflag of 0 filters out grid cells with greater than the
% designated irrigation percentage (IP). politunitflag of 1 filters out
% political units with greater than the designated irrigation percentage.

% switch filter label - PUT THIS IN TITLE?
switch politunitflag
    case 0
        filterlabel = 'gridcellirrfiltered';
    case 1
        filterlabel = 'politunitirrfiltered';
end


% get political unit data if politunitflag ==1
if politunitflag ==1
    
    path = [iddstring 'AdminBoundary2010/Raster_NetCDF/' ...
        '3_M3lcover_5min/admincodes.csv'];
    admincodes = ReadGenericCSV(path);
    
    % build list of 5-letter/number codes for state-level entries and a
    % list of 3-letter/number codes for country-level entries
    for c = 1:length(admincodes.SAGE_ADMIN)
        code = admincodes.SAGE_ADMIN{c};
        admincodes.SAGE_STATE{c} = code(1:5);
        admincodes.SAGE_COUNTRY{c} = code(1:3);
    end
    
    countrycodes = unique(admincodes.SAGE_COUNTRY);
    statecodes = unique(admincodes.SAGE_STATE);
    sagecodes = unique(admincodes.SAGE_ADMIN);
    
end

for IP = IPvec
    for jCrop=[1:16];
        jCrop
        switch jCrop
            case 1
                cropname='wheat';
            case 2
                cropname='maize';
            case 3
                cropname='rice';
            case 4
                cropname='barley';
            case 5
                cropname='rye';
            case 6
                cropname='millet';
            case 7
                cropname='sorghum';
            case 8
                cropname='soybean';
            case 9
                cropname='sunflower';
            case 10
                cropname='potato';
            case 11
                cropname='cassava';
            case 12
                cropname='sugarcane';
            case 13
                cropname='sugarbeet';
            case 14
                cropname='oilpalm';
            case 15
                cropname='rapeseed';
            case 16
                cropname='groundnut';
                
        end
        
        %
        % 1	Wheat
        % 2	Maize
        % 3	Rice
        % 4	Barley
        % 5	Rye
        % 6	Millet
        % 7	Sorghum
        % 8	Soybeans
        % 9	Sunflower
        % 10	Potatoes
        % 11	Cassava
        % 12	Sugar cane
        % 13	Sugar beets
        % 14	Oil palm
        % 15	Rapeseed / Canola
        % 16	Groundnuts / Peanuts
        % 17	Pulses
        % 18	Citrus
        % 19	Date palm
        % 20	Grapes / Vine
        % 21	Cotton
        % 22	Cocoa
        % 23	Coffee
        %
        
        %% Define irrigated mask
        
        % get irrigated area - NOTE: changed this to load up the irrigation
        % summary number from Mueller et al. 2012
        percirrarea = getmircadata(cropname,'irrmax75');
        
        
        % get crop data
        %    S=OpenNetCDF([iddstring '/Crops2000/crops/' name '_5min.nc']);
        S=getcropdata(cropname,DataYear);
        a=S.Data(:,:,1);
        y=S.Data(:,:,2);
        a(a>9e9)=0;
        y(y>9e9)=0;
        a = a.*GetFiveMinGridCellAreas;
        
        % get political unit source info from crop data
        yielddq = S.Data(:,:,4);
        yielddq(yielddq>9e9)=NaN;
        
        switch politunitflag
            case 0
                iirainfed=percirrarea<IP/100;
                ii_irr=percirrarea>=IP/100;
                disp(['Number of rainfed points / cutoff=' num2str(IP) ])
                length(find(iirainfed))
                
            case 1
                % initialize iirainfed
                iirainfed = false(4320,2160);
                
                % set nan irr values to 0
                percirrarea(isnan(percirrarea))=0;
                
                % loop through each country - check for crop area and
                % which political unit level the yield data came from
                for c=1:length(countrycodes)
                    countrycode = countrycodes{c};
                    ctrylogical = CountryCodetoOutlineVector(countrycode);
                    disp(['working on ' cropname ' in ' countrycode]);
                    
                    % if there is area within the country, continue, else
                    % go on to next country
                    if sum(sum(a(ctrylogical)))>0
                        
                        % get the data types in the country
                        ii = isfinite(yielddq) & ctrylogical;
                        ctrydatatypes = unique(yielddq(ii));
                        
                        % cycle through data types
                        for d = 1:length(ctrydatatypes)
                            datatype = ctrydatatypes(d);
                            
                            switch datatype
                                
                                case .25 % country-level
                                    jj = ctrylogical & yielddq==datatype;
                                    irrha = sum(sum(ctrylogical .* ...
                                        percirrarea .* a));
                                    totha = sum(sum(ctrylogical.*a));
                                    irrprop = irrha./totha;
                                    if irrprop<(IP/100)
                                        iirainfed(jj) = 1;
                                    end
                                    
                                case .5 % interpolated
                                    % assume that these areas are 
                                   
                                    
                                case .75
                                    tmp=strmatch(countrycode,statecodes);
                                    snulist = statecodes(tmp);
                                    for s = 1:length(snulist)
                                        snucode = snulist{s};
                                        snulogical = CountryCodetoOutline(snucode);
                                        jj = snulogical&yielddq==datatype;
                                        if sum(sum(jj))>0
                                            irrha = sum(sum(snulogical.*...
                                                percirrarea .* a));
                                            totha = sum(sum(snulogical.*a));
                                            irrprop = irrha./totha;
                                            if irrprop<(IP/100)
                                                iirainfed(jj) = 1;
                                            end
                                        end
                                    end
                                    
                                case 1
                                    tmp=strmatch(countrycode,sagecodes);
                                    snulist = sagecodes(tmp);
                                    for s = 1:length(snulist)
                                        snucode = snulist{s};
                                        snulogical = CountryCodetoOutline(snucode);
                                        jj = snulogical&yielddq==datatype;
                                        if sum(sum(jj))>0
                                            irrha = sum(sum(snulogical.*...
                                                percirrarea .* a));
                                            totha = sum(sum(snulogical.*a));
                                            irrprop = irrha./totha;
                                            if irrprop<(IP/100)
                                                iirainfed(jj) = 1;
                                            end
                                        end
                                    end
                                    
                                case 0
                                    warndlg(['warning: found datatype ' ...
                                        '0 for ' cropname ' in ' ...
                                        countrycode]);
                                    
                                otherwise
                                    warndlg('dont know this datatype')
                            end
                            
                        end
                    end
                end
                
                ii_irr = false(4320,2160);
                ii_irr(a>0)=1;
                ii_irr(iirainfed)=0;
                ii_irr(yielddq==0|yielddq==.5) = 0; 
        end
        
        
        %% Rainfed crops
        a=S.Data(:,:,1);
        y=S.Data(:,:,2);
       
        
        iiareabig=(a>9e9);
        
        a(ii_irr)=0;
        if excludestrangedatatypesflag ==1
            a(yielddq==0|yielddq==.5) = 0; 
        end
        a(iiareabig)=S.missing_value;
        y(ii_irr)=S.missing_value;
        if excludestrangedatatypesflag ==1
            y(yielddq==0|yielddq==.5) = S.missing_value;
        end
        
        S.Data(:,:,1)=a;
        S.Data(:,:,2)=y;
        S.Data=single(S.Data);
        
        [RevNo,RevString,LastChangeRevNo,LCRString,AI]=GetSVNInfo;
        % now write new file
        
        DAS=S;
        DAS=rmfield(DAS,'Data');
        DAS=rmfield(DAS,'Long');
        DAS=rmfield(DAS,'Lat');
        DAS.Title=['Rainfed ' cropname '(Irrigation < ' num2str(IP) ')'];
        DAS.Description1=[num2str(DataYear) ' data and 2000 MIRCA ' ...
            'irrigation data - ' filterlabel];
        DAS.Note1=['svn RevNo=' num2str(RevNo) '. Last changed RevNo= ' ...
            num2str(LastChangeRevNo)];
        DAS.Note2=['calling syntax: politunitflag=' num2str(politunitflag) ...
            ', DataYear=' num2str(DataYear) ...
            ', excludestrangedatatypesflag=' num2str(excludestrangedatatypesflag)];
        
        
    
        writenetcdf(S.Long,S.Lat,S.Data,[cropname 'rainfed' num2str(IP) ], ...
            [cropname 'RF' num2str(IP) '_' filterlabel '_' ...
            int2str(DataYear) '_5min.nc'],DAS)
        
        
        %%  Irrigated crops
        S=OpenNetCDF([iddstring '/Crops2000/crops/' cropname '_5min.nc']);
        a=S.Data(:,:,1);
        y=S.Data(:,:,2);
        
        
        iiareabig=(a>9e9);
        
        a(iirainfed)=0;
        if excludestrangedatatypesflag ==1
            a(yielddq==0|yielddq==.5) = 0; 
        end
        a(iiareabig)=S.missing_value;
        y(iirainfed)=S.missing_value;
        if excludestrangedatatypesflag ==1
            y(yielddq==0|yielddq==.5) = S.missing_value; 
        end
        
        S.Data(:,:,1)=a;
        S.Data(:,:,2)=y;
        S.Data=single(S.Data);
        
        % now write new file
        
        DAS=S;
        DAS=rmfield(DAS,'Data');
        DAS=rmfield(DAS,'Long');
        DAS=rmfield(DAS,'Lat');
        DAS.Title=['Irrigated ' cropname '(Irrigation > ' num2str(IP) ];
        DAS.Description1=[num2str(DataYear) ' data and 2000 MIRCA ' ...
            'irrigation data - ' filterlabel];
        DAS.Note1=['svn RevNo=' num2str(RevNo) '. Last changed RevNo= ' ...
            num2str(LastChangeRevNo)];
        DAS.Note2=['calling syntax: politunitflag=' num2str(politunitflag) ...
            ', DataYear=' num2str(DataYear) ...
            ', excludestrangedatatypesflag=' num2str(excludestrangedatatypesflag)];
        writenetcdf(S.Long,S.Lat,S.Data,[cropname 'irrigated' num2str(IP) ],...
            [cropname 'IRR' num2str(IP) '_' filterlabel '_' ...
            int2str(DataYear) '_5min.nc'],DAS)
        !gzip *.nc
    end
end


% OLD CODE

% ncid = netcdf.open([iddstring '/Irrigation/MIRCA2000_processed/mirca2000_crop' ...
%     int2str(jCrop) '.nc'], 'NC_NOWRITE');
% percirrarea = netcdf.getVar(ncid,6);



