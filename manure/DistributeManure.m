% Script to distribute manure maps from potter et al

%% now parse individual files
% load each one.
% keep top 20 crops.
% also determine total area.
N=8

for Nouter=1:N-1
    Nouter
    S=load(['Workspace' num2str(Nouter)]);
    kk=S.Bounds(Nouter):S.Bounds(Nouter+1);
    
    
    AreaSum_sub=sum(S.Y,1);
    
    TopCrops_sub=S.jj(1:20,:);
    
    AreaSum(kk)=AreaSum_sub;
    TopCrops(1:20,kk)=TopCrops_sub;
end

clear S


load('Workspace1.mat','mnames');


CMii=CropMaskIndices;

% first we write a map of Area

TotalHarvestedArea=datablank;
TotalHarvestedArea(CMii)=AreaSum;

% Here is a detour to make a map of ratio of crop area to total harvested
% area

clear DAS
DAS.Units='fractional area';
DAS.Description='Sum of fractional area associated with all crops (year 2000)';
DAS.ProcessingNotes='Processed Jan 4, 2012.  see jsg052_distribute_manure';
WriteNetCDF(TotalHarvestedArea,'TotalHarvestedArea','TotalHarvestedArea.nc',DAS);

% now prep some manure specific stuff
%like liu
ptem=landmasklogical;
ptem=ptem*0.90;   %entire world
ii=logical(countrycodetooutline('USA'));
ptem(ii)=0.87;
ii=ContinentOutline({'Western Europe','Northern Europe','Southern Europe'});
ptem(ii)=0.66;
ii=CountryCodeToOutline('CAN');
ptem(ii)=0.66;


%% now manure
ManureBaseDir=[ iddstring '/misc/manure'];
SN=OpenGeneralNetCDF([ManureBaseDir '/Nmanure.nc']);
SP=OpenGeneralNetCDF([ManureBaseDir '/Pmanure.nc']);

%ExcessNitrogenPerHa_Avg=en./runningarea;
%ExcessPhosphorusPerHa_Avg=ep./runningarea;

CropArea=OpenNetCDF([iddstring '/Crops2000/Cropland2000_5min.nc']);
PastArea=OpenNetCDF([iddstring '/Crops2000/Pasture2000_5min.nc']);

ca=CropArea.Data;
pa=PastArea.Data;

clear CropArea
clear PastArea


%Nmanure=disaggregate_rate(SN(6).Data,6).*(ca./(pa+ca));  %Estmiate of manure produced on feedlot.
%Pmanure=disaggregate_rate(SP(6).Data,6).*(ca./(pa+ca));

ca(ca>9e9)=0;
pa(pa>9e9)=0;
        
tma=aggregatequantity(fma,6);

ca30min=aggregatequantity(ca,6);
capa30min=aggregatequantity(ca+pa,6);
totalharvarea_30min=aggregatequantity(TotalHarvestedArea,6);

% now we can allocate manure
 for j=1:length(mnames);
        %for j=1:20
        ThisCrop=mnames{j}       
        
        S=OpenNetCDF([iddstring '/Crops2000/crops/' ThisCrop '_5min.nc' ]);
        croparea=S.Data(:,:,1);
        croparea(croparea>9e9)=0;
%        croparea(croparea<(10./fma))=0; % limit to 10 ha
        
      %  ThisCropTransferFunction=(ca./(pa+ca)).*(Area./TotalHarvestedArea);
        
      ii_include=areafilter(croparea,croparea,.9);
      croparea(~ii_include)=0;

        thiscroparea_30min=aggregaterate(croparea,6);
        
        Transfer30min=ca30min./capa30min.*thiscroparea_30min./totalharvarea_30min;
        
        % Nmanure=kg/ha over entire grid cell
        % so total manure N to spread = Nmanure*tma
      
        Nmanure_kg=SN(6).Data.*tma.*Transfer30min;
        Pmanure_kg=SP(6).Data.*tma.*Transfer30min;
        
        Nmanure_kgpercropha=Nmanure_kg./(thiscroparea_30min.*tma);
        Pmanure_kgpercropha=Pmanure_kg./(thiscroparea_30min.*tma);
        
        
        Nmanure_kgpercropha_5min=disaggregate_rate(Nmanure_kgpercropha,6);
        Pmanure_kgpercropha_5min=disaggregate_rate(Pmanure_kgpercropha,6);

        AppliedNitrogenManure=(Nmanure_kgpercropha_5min).*ptem.*(1-0.36);  
        %kg. per gridcell.
        AppliedPhosphorusManure=(Pmanure_kgpercropha_5min).*ptem;  
        
        svnRevNo=getsvninfo;

        DAS.Units='kg/ha';
        DAS.Description =['Applied Nitrogen Per harvested HA (' ThisCrop ')'];
        DAS.CropName=ThisCrop;
        DAS.ProcessingDate=datestr(now);
        DAS.CodeRevNo=svnRevNo;
        WriteNetCDF(single(AppliedNitrogenManure),'AppliedNitrogenManure',['./OutputData/' MakeSafeString(ThisCrop) 'NapprateFromManure' ],DAS );
        S=OpenNetCDF(['./OutputData/NitrogenFromManure' MakeSafeString(ThisCrop)] );
        
        DAS.Units='kg/ha';
        DAS.Description =['Applied Phosphorus Per harvested HA (' ThisCrop ')'];
        DAS.CropName=ThisCrop;
        DAS.ProcessingDate=datestr(now);
        WriteNetCDF(single(AppliedPhosphorusManure),'AppliedPhosphorusManure',['./OutputData/'  MakeSafeString(ThisCrop) 'PapprateFromManure'],DAS );
        S=OpenNetCDF(['./OutputData/PhosphorusFromManure' MakeSafeString(ThisCrop)] );
        
        !gzip ./OutputData/*.nc
        
        
 end
 
                
   


%% have now parsed all of the crops.  Above this code unchanged from
%% jsg032.../croprank
% here, though, we aren't interested in croprank ... rather, we want to
% know total area.


% % % % % % print out
% % % % % for j=1:length(nums)
% % % % %     nums_numeric(j)=str2num(nums{j});
% % % % % end
% % % % % 
% % % % % CMii=CropMaskIndices;
% % % % % 
% % % % % for j=1:20;
% % % % %     PopularCrop=CropMaskLogical*0;
% % % % %     
% % % % %     PopularCrop(CMii)=TopCrops(j,:);
% % % % %     
% % % % %     DAS.Units=['Codes based on alphabet-sorted Monfreda data names. 1=abaca ...' ...
% % % % %         ' 175=yautia'];
% % % % %     DAS.Notes=['Processed ' datestr(now)];
% % % % %     WriteNetCDF(single(PopularCrop),'PrevalentCrop',['PrevalentCropRank' int2str(j) '.nc'],DAS);
% % % % %     %make a version with FAO Codes
% % % % %     
% % % % %     PopCropMonfredaVector=TopCrops(j,:);
% % % % %     PopCropFAOVector=PopCropMonfredaVector*0;
% % % % %     for m=1:length(PopCropMonfredaVector);
% % % % %         thismi=PopCropMonfredaVector(m);
% % % % %         PopCropFAOVector(m)=nums_numeric(thismi);
% % % % %     end
% % % % % 
% % % % %     PopCropFAO=DataBlank;
% % % % %     PopCropFAO(CMii)=PopCropFAOVector;
% % % % %      DAS.Units=['Codes from FAO.  e.g. Maize=56'];
% % % % %     DAS.Notes=['Processed ' datestr(now)];
% % % % %     WriteNetCDF(single(PopCropFAO),'PrevalentCrop',['PrevalentCropRank_FAOCodes_' int2str(j) '.nc'],DAS);   
% % % % % end
