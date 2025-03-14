function [C,N,P,K,ExtraInfo]=CalculateBalancesWithManure_AllCrops(crop,varargin)
% CalculateBalances -
%
% SYNTAX
%     [C,N,P,K,ExtraInfo]=CalculateBalancesWithManure(CROPNAME, optionalargs) will
%     return structure C,N,P,K
%
%     optional arguments include:
%       - 'Nappratemap' (this should be followed by a 5min map of N
%          application rates)
%       - 'Pappratemap' (this should be followed by a 5min map of P2O5
%          application rates)
%       - 'yieldmap' (this should be followed by a 5min map of t/ha yields)
%
%  Example
%   crop='maize'
%   [C,N,P,K,ExtraInfo]=CalculateBalances(crop)
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

persistent D NDS Ndep

FixMethod='linear';
P2O5toPconv = 0.4366; %(31/(31+2.5*16)), 31=atomic mass P, 16 atomic mass O
K2OtoKconv= 0.8298; %(2*39/(2*39+16), 39 = atomic mass K, 16 atomic mass O
% check inputs
newNmapflag = 0;
newPmapflag = 0;
newKmapflag = 0;
newyieldmapflag = 0;
skipNcalcsflag = 0;
skipPcalcsflag = 0;
skipKcalcsflag = 0;
for n = 1:length(varargin)
    thisvar = varargin{n};
    if ischar(thisvar)
        if strmatch(thisvar,'Nappratemap')
            disp(['Using new ' crop ' N application rate map.'])
            newNmapflag = 1;
            AppliedNitrogenPerHA = varargin{n+1};
        elseif strmatch(thisvar,'P2O5appratemap')
            disp(['Using new ' crop ' P2O5 application rate map.'])
            newPmapflag = 1;
            AppliedPhosphorusPerHA = varargin{n+1};
        elseif strmatch(thisvar,'yieldmap')
            disp(['Using new ' crop ' yield map.'])
            newyieldmapflag = 1;
            Yield = varargin{n+1};
        elseif strmatch(thisvar,'skipNcalcs')
            skipNcalcsflag = 1;
        elseif strmatch(thisvar,'skipPcalcs')
            skipPcalcsflag = 1;
        end
    end
end
   
[RevNo,RevString,LCRevNo,LCRevString,AllInfo]=GetSVNInfo(mfilename);
ExtraInfo.SubversionRevNo=RevNo;
ExtraInfo.SubversionLCRevNo=LCRevNo;
ExtraInfo.SubversionLCRevString=LCRevString;


if isempty(D)
    D=ReadGenericCSV([adstring 'croptype_NPK.csv'],2);
    NDS=OpenGeneralNetCDF([iddstring '/misc/NitrogenDeposition/NOyTDEP_S1_5min.nc']);
    Ndep=NDS(1).Data;
    Ndep(Ndep<-9000)=0;
    
    tha=OpenNetCDF([iddstring '/Crops2000/processeddata/TotalHarvestedArea.nc']);
    
    tca=OpenNetCDF([iddstring '/Crops2000/Cropland2000_5min.nc']);
    
    correctionfactor=tca.Data./tha.Data;
    
    correctionfactor(correctionfactor>1)=1;
    
    Ndep=Ndep.*correctionfactor;
end

ExtraInfo.NDepNotes='data from NOyTDEP_S1_5min.nc';


cropnames=D.CROPNAME;

ii=strmatch(crop,cropnames,'exact');

if length(ii)~=1
    error
end

%Nfrac=str2num(D.N_Perc_Dry_Harv(ii))/100;
%Pfrac=str2num(D.P_Perc_Dry_Harv(ii))/100;
Nfrac=(D.N_Perc_Dry_Harv(ii))/100;
Pfrac=(D.P_Perc_Dry_Harv(ii))/100;
Kfrac=(D.K_Perc_Dry_Harv(ii))/100;

Nfixer=D.Nfix_High{ii};
%Nfixer

% open crop data
CS=OpenNetCDF([iddstring '/crops2000/crops/' crop ...
    '_5min.nc']);
Area=CS.Data(:,:,1);
if newyieldmapflag == 0
    Yield=CS.Data(:,:,2);
    disp(['Loading observed ' crop ' yield map.'])
end

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
if skipNcalcsflag == 1
    ii=find(Area==0 | Area > 9e9);
    Area(ii)=0;
    N.Area=Area;
    N.details = 'skipped N';
    ExtraInfo.ManureDataVersion='na';

else
    
    % nitrogen fixation by legumes
    if isequal(D.Legume{ii},'legume')
        switch FixMethod
            case 'linear'
                a=Yield(iigood);
                minyield=min(a);
                maxyield=max(a);
                
                nfixlow=str2num(D.Nfix_Low{ii});
                nfixhi=str2num(D.Nfix_High{ii});
                
                Nfix=datablank;
                Nfix(iigood)=nfixlow+ (a-minyield)./(maxyield-minyield)*(nfixhi-nfixlow);
                
            case 'himedlow'
                %1. Calculate the value of the 30th and 60th percentiles of all yields.
                %2. If yield(i,j) LE 30th percentile then Nfix(i,j) = low mean (see table in attached file)
                %3. If yield(i,j) > 30th and LE 60th percentile then Nfix(i,j) = middle mean (see table)
                %4. If yield(i,j) > 60th percentile then Nfix(i,j) = high mean (see table)
                
                Nfix=datablank;
                
                
                Nfix(Yield <=Y30 & iigood)=str2num(D.Nfix_Low(ii));
                Nfix(Yield <=Y60 & Yield > Y30 & iigood)=str2num(D.Nfix_Med(ii));
                Nfix(Yield > Y60  & iigood)=str2num(D.Nfix_High(ii));
                
            otherwise 'error'
        end
    else
        Nfix=datablank;
    end
    
    % harvested nitrogen
    HarvestedNitrogenPerHA=Yield.*DryFraction*Nfrac*1000;
    
% %     %set max Nfix to harvested N
% %     if Nfix > HarvestedNitrogenPerHA
% %         Nfix = HarvestedNitrogenPerHA
% %     end
   
    jj=find(Nfix > HarvestedNitrogenPerHA);
    if length(jj) > 0
        Nfix(jj)=HarvestedNitrogenPerHA(jj);
    end
    % applied nitrogen
    %    if ~isequal(crop,'soybean')
    if newNmapflag == 0
        disp(['Loading observed ' crop ' N application rate map.'])
        try
            x=load([iddstring '/Fertilizer2000/ncmat/' crop 'Napprate.mat']);
            MissingNfert=0;
            AppliedNitrogenPerHA=x.DS.Data(:,:,1);
            AppliedNitrogenPerHA(isnan(AppliedNitrogenPerHA))=0;

        catch
            disp(['problem with ' crop 'Napprate.mat']);
            C=-1;
            N.ExcessNitrogenPerHA_x_Area=NaN;
            P.ExcessPhosphorusPerHA_x_Area=NaN;
            ExtraInfo.ManureDataVersion='na';
            MissingNfert=1;
            AppliedNitrogenPerHA=datablank;
        end
    end
    
    N.MissingNfert=MissingNfert;  
    %i'm putting in this line knowing it could cause the code to break.
    %MissingNfert is defined within a conditional loop ... if newNmapflag
    %were nonzero then this would lead to a crash.
    
    
    N.NfertPerHA=AppliedNitrogenPerHA;
    
    
    %% now add manure Nitrogen
    DS=OpenNetCDF([iddstring 'manure/apprates/' crop 'NapprateFromManure.nc']);
    x=DS.Data(:,:,1);
    x(~isfinite(x))=0;
    x(x>9e9)=0;
  %  x=x*0;
  %  warning('just added line 214 which breaks calculate balances with manure')
    AppliedNitrogenPerHA=AppliedNitrogenPerHA+x;
    Nmanure=x;
    % end of add manure Nitrogen section
    
    
    ExtraInfo.ManureDataVersion=DS.dataversion;
    
    %%
    ExcessNitrogenPerHA=Ndep+AppliedNitrogenPerHA-HarvestedNitrogenPerHA + Nfix;
    
    N.NmanurePerHA=Nmanure;
    N.Ndeposited=Ndep;
    N.HarvestedNitrogenPerHA=HarvestedNitrogenPerHA;
    N.ExcessNitrogenPerHA=ExcessNitrogenPerHA;
    N.Nfix=Nfix;
    
    N.TotalInputNitrogen=N.Ndeposited+N.NmanurePerHA+N.NfertPerHA;
    
    if isequal(D.CROPNAME{ii},'rice')
  %      N2O=N.TotalInputNitrogen*0.0031;
    disp([' no longer treating rice N2O output differently '])
    end
  %  else
        N2O=N.TotalInputNitrogen*0.01;
  %  end
    
    ii=find(Area==0 | Area > 9e9);
    Area(ii)=0;
    N.ExcessNitrogenPerHA_x_Area=ExcessNitrogenPerHA.*Area;
    N.Area=Area;
    
    N.AppliedNitrogenPerHA=AppliedNitrogenPerHA;
    N.crop=crop;
    N.Nfrac=Nfrac;
    N.DryFraction=DryFraction;
    N.N2O=N2O;
    
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
end


%% Phosphate (P)

if skipPcalcsflag == 1
    P = 'skipped';
else
    if newPmapflag == 0
   try
       disp(['Loading observed ' crop ' P2O5 application rate map.'])
        x=load([iddstring '/Fertilizer2000/ncmat/' crop 'P2O5apprate.mat']);
        AppliedPhosphorusPerHA=x.DS.Data(:,:,1).*P2O5toPconv;
   catch
      disp(['problem loading  ' crop ' P2O5 application rate map.'])
      AppliedPhosphorusPerHA=datablank;
   end
   
   
   end
    
    AppliedPhosphorusPerHA(isnan(AppliedPhosphorusPerHA))=0;
    
    P.PfertPerHA=AppliedPhosphorusPerHA;
    
    
    %% now add manure Phosphorus
    %load(['./CropSpecificManureAdditions/ncmat/PhosphorusFromManure' crop '.mat']);
    DS=OpenNetCDF([iddstring 'manure/apprates/' crop 'PapprateFromManure.nc']);
    
    x=DS.Data(:,:,1);
    x(~isfinite(x))=0;
    x(x>9e9)=0;
    AppliedPhosphorusPerHA=AppliedPhosphorusPerHA+x;
    Pmanure=x;
    % end of add manure Phosphorus section
    
    
    HarvestedPhosphorusPerHA=Yield.*DryFraction*Pfrac*1000;
    ExcessPhosphorusPerHA=AppliedPhosphorusPerHA-HarvestedPhosphorusPerHA;
    P.PmanurePerHA=Pmanure;
    P.ExcessPhosphorusPerHA=ExcessPhosphorusPerHA;
    P.AppliedPhosphorusPerHA=AppliedPhosphorusPerHA;
    P.HarvestedPhosphorusPerHA=HarvestedPhosphorusPerHA;
    P.Pfrac=Pfrac;
    P.crop=crop;
    P.ExcessPhosphorusPerHA_x_Area=ExcessPhosphorusPerHA.*Area;
    
    P.TotalInputPhosphorus=P.PmanurePerHA+P.PfertPerHA;
end
%% K
if skipKcalcsflag == 1
    K = 'skipped';
else
    if newKmapflag == 0
        try
        disp(['Loading observed ' crop ' K2O5 application rate map.'])
        x=load([iddstring '/Fertilizer2000/ncmat/' crop 'K2Oapprate.mat']);
        AppliedPotassiumPerHA=x.DS.Data(:,:,1).*K2OtoKconv;
        catch
            disp(['problem loading ' crop ' K2O5 application rate map.'])
            AppliedPotassiumPerHA=datablank;
            
        end
    end
    %AppliedPotassiumPerHA=datastore([...
    %    'fert_app_ver7/'   crop '_K_ver2_25_rate_FAO_SNS_FINAL.mat']);
    AppliedPotassiumPerHA(isnan(AppliedPotassiumPerHA))=0;
    
    K.KfertPerHA=AppliedPotassiumPerHA;
    
    
% % %     %% now add manure Potassium
% % %     %load(['./CropSpecificManureAdditions/ncmat/PotassiumFromManure' crop '.mat']);
% % %     DS=OpenNetCDF([iddstring 'manure/apprates/' crop 'KapprateFromManure.nc']);
% % %     
% % %     x=DS.Data(:,:,1);
% % %     x(~isfinite(x))=0;
% % %     x(x>9e9)=0;
% % %     AppliedPotassiumPerHA=AppliedPotassiumPerHA+x;
% % %     Kmanure=x;
% % %     % end of add manure Potassium section
    
    
    HarvestedPotassiumPerHA=Yield.*DryFraction*Kfrac*1000;
    ExcessPotassiumPerHA=AppliedPotassiumPerHA-HarvestedPotassiumPerHA;
% % %     K.KmanurePerHA=Kmanure;
    K.ExcessPotassiumPerHA=ExcessPotassiumPerHA;
    K.AppliedPotassiumPerHA=AppliedPotassiumPerHA;
    K.HarvestedPotassiumPerHA=HarvestedPotassiumPerHA;
    K.Kfrac=Kfrac;
    K.crop=crop;
    K.ExcessPotassiumPerHA_x_Area=ExcessPotassiumPerHA.*Area;
    
% % %     K.TotalInputPotassium=K.KmanurePerHA+K.KfertPerHA;
     K.TotalInputPotassium=K.KfertPerHA;
end

return

% end of function.  But here is some code to call this in a loop.


%% code to see how much 
%%%cn=cropnames;
fid=fopen([iddstring 'misc/Reconcile_Monfreda_FAO_cropnames.txt'],'r');
C = textscan(fid,'%s%s%s%s','Delimiter',tab,'HeaderLines',1);
fclose(fid);

nums_unsort=C{1};
cn=C{2};
runningmanureNsum_justmanure=0;
runningmanureNsum_withNfert=0;

runningtotalNsum_justmanure=0;
runningtotalNsum_withNfert=0;


runningNfertsum=0;

runningmanurePsum_justmanure=0;
runningmanurePsum_withNfert=0;
runningPfertsum=0;

runningtotalPsum_justmanure=0;
runningtotalPsum_withNfert=0;

totaln=datablank;
totalp=datablank;
totalexcessn=datablank;
totalexcessp=datablank;
totalarea=datablank;


for j=1:length(cn)
    [c,n,p]=CalculateBalancesWithManure_AllCrops(cn{j});

    ii=CropMaskLogical;
    ha=n.Area(ii).*fma(ii);
    
    
    totaln=totaln+n.AppliedNitrogenPerHA.*n.Area.*fma;
    totalexcessn=totalexcessn+n.ExcessNitrogenPerHA.*n.Area.*fma;
    totalp=totalp+p.AppliedPhosphorusPerHA.*n.Area.*fma;
    totalexcessp=totalp+p.ExcessPhosphorusPerHA.*n.Area.*fma;

    
    
    if n.MissingNfert==1
        runningmanureNsum_justmanure=...
            runningmanureNsum_justmanure+...
            sum(sum(n.NmanurePerHA(ii).*ha));
 
           runningmanurePsum_justmanure=...
            runningmanurePsum_justmanure+...
            sum(sum(p.PmanurePerHA(ii).*ha));
        
        runningtotalNsum_justmanure=...
            runningtotalNsum_justmanure+...
            sum(sum(n.TotalInputNitrogen(ii).*ha));

        runningtotalPsum_justmanure=...
            runningtotalPsum_justmanure+...
            sum(sum(p.TotalInputPhosphorus(ii).*ha));

        
        
    else
        runningmanureNsum_withNfert=...
            runningmanureNsum_withNfert+...
            sum(sum(n.NmanurePerHA(ii).*ha));
  
        runningmanurePsum_withNfert=...
            runningmanurePsum_withNfert+...
            sum(sum(p.PmanurePerHA(ii).*ha));
        
        runningNfertsum=...
            runningNfertsum+...
            sum(sum(n.NfertPerHA(ii).*ha));

          runningPfertsum=...
            runningPfertsum+...
            sum(sum(p.PfertPerHA(ii).*ha));

        runningtotalNsum_withNfert=...
            runningtotalNsum_withNfert+...
            nansum(n.Nfix(ii).*ha)+...
            sum(sum(n.TotalInputNitrogen(ii).*ha));
 
        runningtotalPsum_withNfert=...
            runningtotalPsum_withNfert+...
            sum(sum(p.TotalInputPhosphorus(ii).*ha));

        
    end   
  
end
    
    