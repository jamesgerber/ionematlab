function [outline, indices] = CountryCodetoOutline(countrycode)

% CountryCodetoOutline.m
%
% Syntax: [outline, indices] = CountryCodetoOutline(countrycode);
%    where countrycode is:
%    - a SAGE 3-letter country code OR
%    - a SAGE 5-letter/number code for a state-level political unit OR
%    - a SAGE 8-letter/number code for a county-level political unit
%
% Returns a logical 5 min x 5 min array with 1s for the country of
% interest (outline). Will also return indices if two output arguments are
% requested.
%
% Examples:
%    [outline] = CountryCodetoOutline('USA');
%    [outline] = CountryCodetoOutline('USA01');
%    [outline, ii] = CountryCodetoOutline('CAN');
%
% ***IMPORTANT NOTES***: The first time this code is run, you will have to
% build a .mat file of hash tables using raw AdminBoundary info. This will
% likely take ~20 minutes(!). You may also need to change the Java Heap
% Space for Matlab to 256 MB, else Matlab may not be able to save the hash
% tables. To see how to increase Java memory, see this MathWorks tutorial:
% http://www.mathworks.com/support/solutions/en/data/1-18I2C/
%
% Written by Nathan Mueller
% last modified 7.6.2010
%
% see also StandardCountryNames.m


persistent snu_htable state_htable ctry_htable ctry_outlines

SystemGlobals;

% check to see if the 'state_htable' hash table exists in memory
if isempty(snu_htable);
    
    % if the hash table doesn't exist, try to load it from misc folder
    ht_path = [IoneDataDir '/misc/admin_hashtable.mat'];
    if exist(ht_path) == 2
        eval(['load ' ht_path]);
        
        % if it doesn't exist in the folder, construct the hash table using
        % AdminBoundary data
    else
        
        path = [IoneDataDir 'AdminBoundary2005/Raster_NetCDF/' ...
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
        
        
        path = [IoneDataDir 'AdminBoundary2005/Raster_NetCDF/3_M3lcover_5min/' ...
            'admin_5min.nc'];
        [DS] = OpenNetCDF(path);
        AdminGrid = DS.Data;
        
        % Create hash table for AdminBoundary codes - this cuts down on the
        % look-up time for creating logical arrays of country outlines.
        disp('Creating hash table for SAGE_ADMIN codes and values in 5 min grid')
        pb_htable = java.util.Properties;
        for n = 1:length(admincodes.SAGE_ADMIN)
            pb_htable.put(admincodes.SAGE_ADMIN{n},admincodes.Value_in_5min_bdry_file(n));
        end
        
        disp('Creating hash table for SAGE_ADMIN codes and map indices')
        
        snu_htable = java.util.Properties;
        
        for c = 1:length(sagecodes);
            sagecode = sagecodes{c};
            disp(sagecode);
            gridno = pb_htable.get(sagecode);
            ii = find(AdminGrid == gridno);
            if ~isempty(ii)
                snu_htable.put(sagecode,ii);
            end
        end
        
        disp(['Creating hash table for SAGE_STATE codes ' ...
            'and SAGE_ADMIN codes'])
        
        state_htable = java.util.Properties;
        
        for c = 1:length(statecodes);
            statecode = statecodes{c};
            disp(statecode);
            staterows = strmatch(statecode, admincodes.SAGE_STATE);
            sagecodes = admincodes.SAGE_ADMIN(staterows);
            state_htable.put(statecode,sagecodes);
        end
        
        %         disp('Creating hash table for SAGE_COUNTRY codes and SAGE_ADMIN codes')
        %
        %         for c = 1:length(countrycodes);
        %             ccode = countrycodes{c};
        %             disp(ccode);
        %             countryrows = strmatch(ccode, admincodes.SAGE_COUNTRY);
        %             sagecodes = admincodes.SAGE_ADMIN(countryrows);
        %             state_htable.put(ccode,sagecodes);
        %         end
        
        disp('Creating outlines and hash table for SAGE_COUNTRY codes')
        
        ctry_outlines = zeros(4320,2160);
        ctry_htable = java.util.Properties;
        for c = 1:length(countrycodes);
            ccode = countrycodes{c};
            disp(ccode);
            countryrows = strmatch(ccode, admincodes.SAGE_COUNTRY);
            ac = admincodes.SAGE_ADMIN(countryrows);
            for n = 1:length(ac)
                code = ac{n};
                gridno = pb_htable.get(code);
                ii = find(AdminGrid == gridno);
                if ~isempty(ii)
                    ctry_outlines(ii) = c;
                end
            end
            ctry_htable.put(ccode,c);
        end
        
        savepath = ['save ' IoneDataDir '/misc/admin_hashtable.mat ' ...
            'snu_htable state_htable ctry_htable ctry_outlines'];
        eval(savepath);
        
    end
end

if length(countrycode) == 3;
    
    c = ctry_htable.get(countrycode);
    indices = find(ctry_outlines == c);
    outline = zeros(4320,2160);
    outline(indices) = 1;
    
elseif length(countrycode) == 5;
    outline = zeros(4320,2160);
    sagecodes = state_htable.get(countrycode);
    indices = [];
    for c = 1:length(sagecodes);
        sc = sagecodes(c);
        ii = snu_htable.get(sc);
        indices = [indices; ii];
    end
    outline(indices) = 1;
    
elseif length(countrycode == 8);
    
    outline = zeros(4320,2160);
    indices = snu_htable.get(countrycode);
    outline(indices) = 1;
    
else
    
    warning('invalid SAGE code');
    
end





% %
% %         outline = zeros(4320,2160);
% %         for n = 1:length(ac)
% %             code = ac{n};
% %             gridno = pb_htable.get(code);
% %             ii = find(AdminGrid == gridno);
% %             if ~isempty(ii)
% %                 outline(ii) = 1;
% %             end
% %         end
% %         ii = find(outline == 1);
% %         if ~isempty(ii)
% %             state_htable.put(statecode,ii);
% %         end
% %     end
% %
% %     disp('Creating hash table for SAGE_COUNTRY codes and SAGE_ADMIN codes')
% %
% %     for c = 1:length(countrycodes);
% %         ccode = countrycodes{c};
% %         disp(ccode);
% %         countryrows = strmatch(ccode, admincodes.SAGE_COUNTRY);
% %         ac = admincodes.SAGE_ADMIN(countryrows);
% %         outline = zeros(4320,2160);
% %         for n = 1:length(ac)
% %             code = ac{n};
% %             gridno = pb_htable.get(code);
% %             ii = find(AdminGrid == gridno);
% %             if ~isempty(ii)
% %                 outline(ii) = 1;
% %             end
% %         end
% %         ii = find(outline == 1);
% %         if ~isempty(ii)
% %             state_htable.put(ccode,ii);
% %         end
% %     end




%  disp('Creating hash table for SAGE_STATE codes and map indices')
%
%         for c = 1:length(statecodes);
%             statecode = statecodes{c};
%             disp(statecode);
%             staterows = strmatch(statecode, admincodes.SAGE_STATE);
%             ac = admincodes.SAGE_ADMIN(staterows);
%             outline = zeros(4320,2160);
%             for n = 1:length(ac)
%                 code = ac{n};
%                 gridno = pb_htable.get(code);
%                 ii = find(AdminGrid == gridno);
%                 if ~isempty(ii)
%                     outline(ii) = 1;
%                 end
%             end
%             ii = find(outline == 1);
%             if ~isempty(ii)
%                 state_htable.put(statecode,ii);
%             end
%         end
%
%         disp('Creating hash table for SAGE_COUNTRY codes and map indices')
%
%         for c = 1:length(countrycodes);
%             ccode = countrycodes{c};
%             disp(ccode);
%             countryrows = strmatch(ccode, admincodes.SAGE_COUNTRY);
%             ac = admincodes.SAGE_ADMIN(countryrows);
%             outline = zeros(4320,2160);
%             for n = 1:length(ac)
%                 code = ac{n};
%                 gridno = pb_htable.get(code);
%                 ii = find(AdminGrid == gridno);
%                 if ~isempty(ii)
%                     outline(ii) = 1;
%                 end
%             end
%             ii = find(outline == 1);
%             if ~isempty(ii)
%                 state_htable.put(ccode,ii);
%             end
%         end



% % %
% % %
% % % else
% % %
% % %     workingdir = pwd;
% % %
% % %     %     str = ([IoneDataDir 'misc']);
% % %     %     cd(str);
% % %     %     load 5mincountries;
% % %     %     cd(workingdir);
% % %
% % %     loadpath = ['load ' IoneDataDir '/misc/5mincountries.mat'];
% % %     eval(loadpath);
% % %
% % %     state_htable = java.util.Properties;
% % %     for j=1:length(co_codes);
% % %         code = co_codes{j};
% % %         tmp = co_numbers(j);
% % %         ii = find(co_outlines == tmp);
% % %         if ~isempty(ii)
% % %
% % %             state_htable.put(co_codes{j},ii);
% % %         end
% % %
% % %     end
% % %
% % % end
% % %
% % % outline = zeros(4320,2160);
% % % ii = state_htable.get(countrycode);
% % % outline(ii) = 1;
% % %
% % % %
% % % % try
% % % %
% % % %     ii = state_htable.get(countrycode);
% % % %
% % % % catch