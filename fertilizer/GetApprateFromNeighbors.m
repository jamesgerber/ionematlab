function Apprate=GetApprateFromNeighbors(CountryCode);

Neighbors = GetBestNeighbors(CountryCode);

 for m = 1:length(NeighborCodesSage)
            neighborcode = NeighborCodesSage{m}
            
            if length(NeighborCodesSage)>0% there are neighbors
                
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
                    
                    disp(['Filling in data for ' sagecountryname ' with' ...
                        ' average application rate data from ' neighborlist]);
                    
                    ii = find(ctry_appratemap == -9);
                    appratemap(ii) = avgneighbor;
                    
                end
                
            else
                disp(['No neighbors available for ' sagecountryname]);
            end