function [C,N,P]=CalculateBalances(crop)
% CalculateBalances -
%
% SYNTAX
%     [C,N,P]=CalculateBalances(CROPNAME) will return structure C,N
%
%  Example
%   crop='maize'
%   [C,N,P]=CalculateBalances(crop)
%   NSS.cmap='nathangreenscale2';
%   NSS.coloraxis=[0 250];
%   NSS.TitleString =['applied nitrogen (' crop ')']
%   NSS.FileName=['Applied Nitrogen ' crop '']
%   NiceSurfGeneral(N.ExcessNitrogenPerHA,NSS);
%   NiceSurfGeneral(N.AppliedNitrogenPerHA,NSS);
%
%   clear NSS
%    NSS.ColorAxis=[-.99];
%    NSS.cmap='sixteencolors';
%    NSS.Units='kg N/ha';
%    NSS.TitleString =['excess nitrogen (' crop ')']
%    NSS.FileName=['Excess Nitrogen ' crop '']
%    NiceSurfGeneral(N.ExcessNitrogenPerHA,NSS);

FixMethod='linear';


persistent D NDS Ndep

if isempty(D)
    D=ReadGenericCSV([adstring 'croptype_NPK.csv'],2);
    NDS=OpenGeneralNetCDF(['NOyTDEP_S1_5min.nc']);
    Ndep=NDS(1).Data;
    Ndep(Ndep<-9000)=0;
end

cropnames=D.CROPNAME;

ii=strmatch(crop,cropnames,'exact');

if length(ii)~=1
    error
end

%Nfrac=str2num(D.N_Perc_Dry_Harv(ii))/100;
%Pfrac=str2num(D.P_Perc_Dry_Harv(ii))/100;
Nfrac=(D.N_Perc_Dry_Harv(ii))/100;
Pfrac=(D.P_Perc_Dry_Harv(ii))/100;

Nfixer=D.Nfix_High{ii};
Nfixer


CS=OpenNetCDF([iddstring '/crops2000/crops/' crop ...
    '_5min.nc']);


Area=CS.Data(:,:,1);
Yield=CS.Data(:,:,2);

iigood=(CropMaskLogical & Area > 0 & Yield < 9e9);
Production=Area.*Yield.*GetFiveMinGridCellAreas;
totalProduction=sum(Production(iigood));

%% find 30th and 60th percentile weighted yields
Y30=AreaWeightedPercentile(Area(iigood).*GetFiveMinGridCellAreas(iigood),Yield(iigood),.375);
Y60=AreaWeightedPercentile(Area(iigood).*GetFiveMinGridCellAreas(iigood),Yield(iigood),.625);

% here is some code to make sure that areas work out as expected
%ii=find(Yield >= Y60 & Yield > 0 & Area > 0 & Area < 10);
%sum(sum(Area(ii).*GetFiveMinGridCellAreas(ii)))

%%
DryFraction=D.Dry_Fraction(ii);
HI=D.Harvest_Index(ii);
AGF=D.Aboveground_Fraction(ii);

YieldToCarbonFactor= 0.45/(HI*AGF);
TotalCarbonFactor= DryFraction*(0.45/(HI*AGF));

%% Dep
C.YieldToCarbonFactor=YieldToCarbonFactor;

%% Nitrogen

% fixed nitrogen
if isequal(D.Legume{ii},'legume')
    
    
    
    switch FixMethod
        case 'linear'
            a=Yield(iigood);
            minyield=min(a);
            maxyield=max(a);
            
            nfixlow=str2num(D.Nfix_Low{ii});
            nfixhi=str2num(D.Nfix_High{ii});
            
            Nfix=DataBlank;
            Nfix(iigood)=nfixlow+ (a-minyield)./(maxyield-minyield)*(nfixhi-nfixlow);
            
        case 'himedlow'
            %1. Calculate the value of the 30th and 60th percentiles of all yields.
            %2. If yield(i,j) LE 30th percentile then Nfix(i,j) = low mean (see table in attached file)
            %3. If yield(i,j) > 30th and LE 60th percentile then Nfix(i,j) = middle mean (see table)
            %4. If yield(i,j) > 60th percentile then Nfix(i,j) = high mean (see table)
            
            Nfix=DataBlank;
            
            
            Nfix(Yield <=Y30 & iigood)=str2num(D.Nfix_Low(ii));
            Nfix(Yield <=Y60 & Yield > Y30 & iigood)=str2num(D.Nfix_Med(ii));
            Nfix(Yield > Y60  & iigood)=str2num(D.Nfix_High(ii));
            
        otherwise 'error'
            
            
            
    end
    
    
    
else
    Nfix=DataBlank;
end



HarvestedNitrogenPerHA=Yield.*DryFraction*Nfrac*1000;


%    if ~isequal(crop,'soybean')
try
    x=load([iddstring '/Fertilizer2000/ncmat/' crop 'Napprate.mat']);
catch
    disp(['problem with ' crop 'Napprate.mat']);
    C=-1;
    N.ExcessNitrogenPerHA_x_Area=NaN;
    P.ExcessPhosphorusPerHA_x_Area=NaN;
    return
end

AppliedNitrogenPerHA=x.DS.Data(:,:,1);   
AppliedNitrogenPerHA(isnan(AppliedNitrogenPerHA))=0;

% per 
%AppliedNitrogenPerHA=datastore([...
%    'fert_app_ver7/'   crop '_N_ver2_25_rate_FAO_SNS_FINAL.mat']);
%    else
%      AppliedNitrogenPerHA=HarvestedNitrogenPerHA*0;
%    end

ExcessNitrogenPerHA=Ndep+AppliedNitrogenPerHA-HarvestedNitrogenPerHA + Nfix;

N.Ndeposited=Ndep;
N.HarvestedNitrogenPerHA=HarvestedNitrogenPerHA;
N.ExcessNitrogenPerHA=ExcessNitrogenPerHA;
N.Nfix=Nfix;

ii=find(Area==0 | Area > 9e9);
Area(ii)=0;
N.ExcessNitrogenPerHA_x_Area=ExcessNitrogenPerHA.*Area;
N.Area=Area;

N.AppliedNitrogenPerHA=AppliedNitrogenPerHA;
N.crop=crop;
N.Nfrac=Nfrac;
N.DryFraction=DryFraction;

if ~isempty(Nfixer)
    N.Nfixer=1;
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    '!!!!!!!!!!!!!!!!!!!!!!!!!!!'
else
    N.Nfixer=0;
end


%% Phosphate (P)
x=load([iddstring '/Fertilizer2000/ncmat/' crop 'P2O5apprate.mat']);
AppliedPhosphorusPerHA=x.DS.Data(:,:,1)*0.4366; %(31/(31+2.5*16)), 31=atomic mass P, 16 atomic mass O
%AppliedPhosphorusPerHA=datastore([...
%    'fert_app_ver7/'   crop '_P_ver2_25_rate_FAO_SNS_FINAL.mat']);
AppliedPhosphorusPerHA(isnan(AppliedPhosphorusPerHA))=0;



HarvestedPhosphorusPerHA=Yield.*DryFraction*Pfrac*1000;
ExcessPhosphorusPerHA=AppliedPhosphorusPerHA-HarvestedPhosphorusPerHA;
P.ExcessPhosphorusPerHA=ExcessPhosphorusPerHA;
P.AppliedPhosphorusPerHA=AppliedPhosphorusPerHA;
P.HarvestedPhosphorusPerHA=HarvestedPhosphorusPerHA;
P.Pfrac=Pfrac;
P.crop=crop;
P.ExcessPhosphorusPerHA_x_Area=ExcessPhosphorusPerHA.*Area;

return



