function Neighbors=GetBestNeighbors(CountryCode,RecursionLevel,GoodCountries);
%GetBestNeighbors
 %sagecountryname=StandardCountryNames(countrycode,'sage3','sage3');

 if nargin==1
   RecursionLevel=1;
 end
 
 if nargin==2
     GoodCountries=[];
 end
 
  
 
 [NeighborCodesSage,NeighborNamesSage,AvgDistance] ...
                    = NearestNeighbor(CountryCode,RecursionLevel);
 FirstLevelNeighborCodes=NeighborCodesSage;
 ISO3Neighbors=StandardCountryNames(NeighborCodesSage,'sage3','ISO3');
 ISO3Self=StandardCountryNames(CountryCode,'sage3','ISO3'); 
 
 GADMNeighborStats=GADMDataGateway(ISO3Neighbors);
 GADMSelfStats=GADMDataGateway(ISO3Self);


 % look to see if there are countries with same WBINCOME
 % and if applicabe, countries that are in goodcountries
 
 SelfIncome=GADMSelfStats.WBINCOME;
 
 [x{1:length(GADMNeighborStats)}]=deal(GADMNeighborStats.WBINCOME);

 ii=strmatch(SelfIncome,x);
 
 iikeep=[];
 Neighbors=NeighborCodesSage(ii);
 
 if ~isempty(GoodCountries);
 
     for j=1:length(Neighbors);
         if strmatch(Neighbors(j),GoodCountries)
             %found a neighbor who has nec. attirbutes.
             iikeep=ii(j);
         end
     end
 else
     iikeep=ii;
 end
 
 
 if ~isempty(iikeep)
   %Neighbors=IS03Neighbors(ii);
   Neighbors=NeighborCodesSage(iikeep);
 else

   %first thing to try: increase recursion level
   if RecursionLevel==1
       Neighbors=GetBestNeighbors(CountryCode,2,GoodCountries);
   end
   %% note ... can only return empty if recursionlevel==2
   if isempty(Neighbors)
     if RecursionLevel==2
       % return empty
       Neighbors='';
     else
       % Recursion level is 1.  If we are here, it can only mean
       % that we tried recursion level 2 but didn't find a
       % country with same WBINCOME.  Now we have to make do with
       % what we have. 
       
       
     warning(' no one with same WBINCOME & attributes.  Returning all neighbs')
     Neighbors=GetBestNeighbors(CountryCode,1);
     end
   end
end   
 
   
 