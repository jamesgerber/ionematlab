function SoilProps=SoilPartsToSoilProperties(SoilPartStructure,PE,Layer);
% SoilPartsToSoilProperties - given soil types, combine their
% properties.

%keyboard

%ThisParameter=getfield(PE,Prop);

counter=0;
for j=length(SoilPartStructure):-1:1;  %reason for going backwards below ...
    SPS=SoilPartStructure(j);
    ThisPRID=SPS.PRID{1};
    ii=strmatch(ThisPRID,PE.PRID,'exact');
    iRowInPE=ii(strmatch(Layer,PE.Layer(ii)));
    
    
    tmpBULK=PE.BULK(iRowInPE);
    tmpTOTC=PE.TOTC(iRowInPE);
    tmpTOTN=PE.TOTN(iRowInPE);
    tmpTAWC=PE.TAWC(iRowInPE); % avail water capacity cm/m
    tmpSDTO=PE.SDTO(iRowInPE); % sand (mass %)
    tmpCLPC=PE.CLPC(iRowInPE); % clay (mass %)
    tmpPHAQ=PE.PHAQ(iRowInPE); % PH in water
    tmpPERC=SPS.PROP;
    tmpECEC=PE.ECEC(iRowInPE);
    tmpELCO=PE.ELCO(iRowInPE);
    
    if PE.TOTC(iRowInPE) < 0
        disp(['This soil types has a flag indicating it''s not a' ...
            ' standard soil ...']);
    else
        counter=counter+1;
        BULK(counter)=tmpBULK;%need this for TOTC average
        TOTC(counter)=tmpTOTC;%TOTC
        TOTN(counter)=tmpTOTN;%TOTC
        CLPC(counter)=tmpCLPC;
        SDTO(counter)=tmpSDTO;
        TAWC(counter)=tmpTAWC;
        PHAQ(counter)=tmpPHAQ;
        ECEC(counter)=tmpECEC;
        ELCO(counter)=tmpELCO;
        Percentage(counter)=tmpPERC;
    end
end


if counter==0
    %counter is still equal to zero.
    %just take those temp values.  Because we went through
    %SoilPartStructure backwards before, we now have the flag values
    %corresponding to the largest percentage.
    SoilProps.AvgTOTN=tmpTOTN;
    SoilProps.AvgTOTC=tmpTOTC;
    SoilProps.AvgBULK=tmpBULK;
    SoilProps.AvgTAWC=tmpTAWC;
    SoilProps.AvgCLPC=tmpCLPC;
    SoilProps.AvgSDTO=tmpSDTO;
    SoilProps.AvgPHAQ=tmpPHAQ;
    SoilProps.MedianTOTN=tmpTOTN;
    SoilProps.MedianTOTC=tmpTOTC;
    SoilProps.MedianBULK=tmpBULK;
    SoilProps.MedianTAWC=tmpTAWC;
    SoilProps.MedianCLPC=tmpCLPC;
    SoilProps.MedianSDTO=tmpSDTO;
    SoilProps.MedianPHAQ=tmpPHAQ;
    SoilProps.ModalTAWC=tmpTAWC;
    SoilProps.MedianTAWC=tmpTAWC;
    SoilProps.MedianECEC=tmpECEC;
    SoilProps.MedianELCO=tmpELCO;
    return
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTC - carbon density %
%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % Avg carbon density
% % % % CarbonDensity=TOTC.*BULK;   %units of gC/(dm^3)
% % % % 
% % % % % This can be averaged by soil proportion
% % % % WeightedCarbonDensity=sum(CarbonDensity.*Percentage)./ ...
% % % %     sum(Percentage);  %units gC/(dm^3)
% % % % 
% % % % % Now determine an average bulk density
% % % % WeightedBulkDensity= sum(BULK.*Percentage)./ ...
% % % %     sum(Percentage);   %units kg/(dm)^3
% % % % 
% % % % %Averaged carbon fraction
% % % % SoilProps.AvgTOTC=WeightedCarbonDensity./WeightedBulkDensity;  %Units gC/kg
%%%%%%%replaced the above with this:
SoilProps.AvgTOTC=BulkWeightedAverage(TOTC,BULK,Percentage);
SoilProps.AvgTOTC_Units='gC/kg';
% average for total carbon.

S=soilpropaverages(TOTC,Percentage);
SoilProps.MedianTOTC=S.median;



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTN - nitrogen density %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% average for total nitrogen.
S=soilpropaverages(TOTN,Percentage);

SoilProps.AvgTOTN=BulkWeightedAverage(TOTN,BULK,Percentage);
SoilProps.MedianTOTN=S.median;
SoilProps.AvgTOTN_Units='gN/kg';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BULK-WeightedBulkDensity %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WeightedBulkDensity= sum(BULK.*Percentage)./sum(Percentage);
SoilProps.AvgBULK=WeightedBulkDensity;
S=soilpropaverages(BULK,Percentage);
SoilProps.MedianBULK=S.median;

%SoilProps.AvgTOTN=BulkWeightedAverage(BULK,1,Percentage);
SoilProps.AvgBULK_Units='kg/dm^3';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CLPC - percentage clay  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SoilProps.AvgCLPC=BulkWeightedAverage(CLPC,BULK,Percentage);
SoilProps.AvgCLPC_Units='% Clay';
S=soilpropaverages(CLPC,Percentage);
SoilProps.MedianCLPC=S.median;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SDTO - percentage sand  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SoilProps.AvgSDTO=BulkWeightedAverage(SDTO,BULK,Percentage);
SoilProps.AvgSDTO_Units='% Sand';
S=soilpropaverages(SDTO,Percentage);
SoilProps.MedianSDTO=S.median;

%%
%%%%%%%%%%%%%%%%%%%%%%%%
%  PHAQ - PH in water  %
%%%%%%%%%%%%%%%%%%%%%%%%
MolarHydrogen=10.^(-PHAQ);
AvgMH=sum(MolarHydrogen.*Percentage)./sum(Percentage);
AvgPH=-log10(AvgMH);
SoilProps.AvgPHAQ=AvgPH;
SoilProps.AvgPHAQ_Units='PH';
S=soilpropaverages(PHAQ,Percentage);
SoilProps.MedianPHAQ=S.median;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  TAWC - total available water capacity  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SoilProps.AvgTAWC=sum(TAWC.*Percentage)/sum(Percentage);

S=soilpropaverages(TAWC,Percentage);
SoilProps.ModalTAWC=S.modalvalue;
SoilProps.MedianTAWC=S.median;
SoilProps.AvgTAWC_Units='cm/m';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ECEC - effective CEC  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S=soilpropaverages(ECEC,Percentage);

SoilProps.MedianECEC=S.median; 
SoilProps.MedianECEC_Units=' cmol_c / kg';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ELCO - elec conductivity  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S=soilpropaverages(ELCO,Percentage);

SoilProps.MedianELCO=S.median;
SoilProps.MedianELCO_Units=' dS / m';


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BulkWeightedAverage  function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BWA=BulkWeightedAverage(X,BULK,Weight);
% BulkWeightedAverage
% Example:  WeightedCarbonDensity=BulkWeightedAverage(TOTC,BULK,Percentage)
Xdensity=X.*BULK;
WeightedXdensity=sum(Xdensity.*Weight)/sum(Weight);
WeightedBulkDensity=sum(BULK.*Weight)/sum(Weight);
BWA=WeightedXdensity/WeightedBulkDensity;






