%% find entropy

%Get country outline
[CountryOutline,CountryCodeList,OutputCountryNameList]= ...
    CountryNameToOutline;

clear Hbin Nbin

COvector=CountryOutline(DataMaskIndices);
CMvector=ClimateMask(DataMaskIndices);
CAvector=CultivatedArea(DataMaskIndices);

for ibincounter=1:length(ListOfBins)
%  for ibincounter=16;
  % ibin takes on each climate bin.  Find H for each climate bin.
  ibin=ListOfBins(ibincounter)
  BinMask=(CMvector==ibin & CAvector>0);

  Countries=COvector(BinMask);
  CountriesInThisBin=unique(Countries);
  S=length(CountriesInThisBin);

  clear nvect
    for i=1:length(CountriesInThisBin)
    % i takes on one value for each country
    ThisCountry=CountriesInThisBin(i);
    jj=find(COvector==ThisCountry & BinMask);
    
    nvect(i)=sum(CAvector(jj));
  end

  if length(CountriesInThisBin)
    N=sum(nvect);
    pvect=nvect/N;
    
    Hbin(ibincounter)=-sum(pvect.*log(pvect))-(S-1)/(2*N);
    Nbin(ibincounter)=N;
  else
    Hbin(ibincounter)=0;
    Nbin(ibincounter)=0;
  end    
  
  
    
end

WeightedHbin=sum(Hbin.*Nbin)./sum(Nbin);