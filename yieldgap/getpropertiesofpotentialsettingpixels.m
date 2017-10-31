function P=getpropertiesofpotentialsettingpixels(climatemask,yieldmask,areamask,variable,pylist);
% getpropertiesofpotentialsettingpixels what are properties that govern the
% potential setting pixels
%
%   S=getpropertiesofpotentialsettingpixels(climatemask,variable);
%  
%   per capita GDP often used

ibins=unique(climatemask);

ibins=ibins(isfinite(ibins));
ibins=ibins(~ibins==0);

FifthPercentileArea=areaweightedpercentile(areamask,areamask,.05);
variable(variable==variable(1))=nan;

mapofgoverningaveragevariable=datablank;
mapofgoverningmodalcountrynumber=datablank;

%%
for j=1:length(ibins)
    bin=ibins(j);
    jjbin=climatemask==ibins(j);
    jj=(jjbin & isfinite(areamask) & isfinite(yieldmask) ...
        & areamask > FifthPercentileArea);
    
    a=areamask(jj);
    y=yieldmask(jj);
    v=variable(jj);
    jjindices=find(jj);
    
   % py=areaweightedpercentile(a,y,.95)
    %    pylist(j)
    %  pause
    kk=(y>=pylist(j));
  %  kkbig=(yieldmask > pylist(j)) & jj;
        kkindicesintomap=jjindices(kk);

  %  length(find(kk))/length(kk)
  %  sum(a(kk))/sum(a)
 %   disp('***')
    governingvarvalue(j)=nansum(v(kk).*a(kk))./nansum(a(kk));
    
    if length(find(kk)) > 0
   [CountryNumbers,CountryNames]=GetCountry5min(kkindicesintomap);
%   [CountryNumbers,CountryNames]=GetCountry(kkindicesintomap);
 
  modalcountrynumber=mode(CountryNumbers);
  [~,idx]=find(CountryNumbers==modalcountrynumber);
  CountryNameVector{j}=CountryNames{idx(1)};

  % now paint onto climate bin
  mapofgoverningaveragevariable(jjbin)=governingvarvalue(j);
mapofgoverningmodalcountrynumber(jjbin)=modalcountrynumber;
  
    else
          mapofgoverningaveragevariable(jjbin)=nan;
mapofgoverningmodalcountrynumber(jjbin)=nan;
  CountryNameVector{j}='null';

    end
    
end
P.CountryNameVector=CountryNameVector;
P.governingvarvalue=governingvarvalue;
P.mapofgoverningaveragevariable=mapofgoverningaveragevariable;
P.mapofgoverningmodalcountrynumber=mapofgoverningmodalcountrynumber;
