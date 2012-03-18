function [S]=getirrigationvolume(crop)
% getirrigationvolume - return seibert irrigation data
%
%
%   SYNTAX:
%
%       [S]=getirrigationvolume(crop) where crop can be a number
%       from 1-26, or a name.
%
%       S will contain fields
%       S.cropname
%       S.cropnumber
%       S.IrrYield
%       S.IrrHarvArea
%       S.IrrBlue
%       S.IrrGreen
%       S.RainfedYield
%       S.RainfedHarvArea
%       S.RainfedBlue
%       S.RainfedGreen
%       S.Units
%
%




% % Units:

% Harvested area (AH): ha/yr
% 
% Yield: t/(ha yr)
% 
% Water use: mm/yr



croplist=getcroplist;



SeibertNames=croplist(1:3:end);
%SeibertNums=croplist(2:3:end);
SeibertNums=croplist(2:3:end);
MonfredaNames=croplist(3:3:end);

if isnumeric(crop)
    
    S.cropnumber=crop;
    ii=find(SeibertNums==crop);
    S.cropname=MonfredaNames{ii};    
    CS=getdata(S.cropname); %cropstruct
end

if isstr(crop)
    ii=strmatch(crop,MonfredaNames,'exact');
    if numel(ii)~=1
        error(['bad match of monfreda names in ' mfilename]);
    end
    
    CropNo=SeibertNums{ii};
    IAH=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/AH_CROP'...
        CropNo '.mat']);
    
    RAH=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/AH_CROP'...
        int2str(str2num(CropNo)+29) '.mat']);   
    
    IY=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'YIELD_CROP'  CropNo '_1998_2002.mat']);
    
    RY=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'YIELD_CROP'  int2str(str2num(CropNo)+29) '_1998_2002.mat']);
    
    % 
    jj=strmatch(crop,{'maize','rye','sorghum'},'exact');
    if numel(jj)==1
        % special case ... these are forage crops.  Since water use isn't
        % differentiated between the two, we need to take the forage area
        % into account when we calculate usage per unit area
        switch jj
            case 1
                ForCropNo='27';
            case 2
                ForCropNo='28';
            case 3
                ForCropNo='29';
        end
        
        IAHfor=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/AH_CROP'...
            ForCropNo '.mat']);
        
        RAHfor=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/AH_CROP'...
            int2str(str2num(ForCropNo)+29) '.mat']);
%         
%         IYfor=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
%             'YIELD_CROP'  ForCropNo '_1998_2002.mat']);
%         
%         RYfor=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
%             'YIELD_CROP'  int2str(str2num(ForCropNo)+29) '_1998_2002.mat']);
%         
%         
    else
        
        IAHfor.Data=datablank;
        RAHfor.Data=datablank;
%         IYfor.Data=datablank;
%         RYfor.Data=datablank;
        
    end
    
            
    
    
    IG=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_IRC_GREEN_05_MM_C'  CropNo '_1998_2002.mat']);
    
    RG=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_RFC_GREEN_05_MM_C'  CropNo '_1998_2002.mat']);
    
    IB=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_IRC_BLUE_05_MM_C'  CropNo '_1998_2002.mat']);
    
    RB=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_RFC_BLUE_05_MM_C'  CropNo '_1998_2002.mat']);


    
    % these are straightforward 
    S.IrrHarvArea=IAH.Data./fma;
    S.RainfedHarvArea=RAH.Data./fma;
    S.IrrYield=IY.Data;
    S.RainfedYield=RY.Data;
    
    % want units of water use ... irr data are in mm/grid cell/yr  
    % so we divide by normalized area to get mm/ha.  Since Stefan's area is
    % in ha, we divide his area by fiveminuteareas.
    
    % Green is rain
    % Blue is irrigation
    
    S.IrrGreen=(IG.Data)./(IAH.Data./fma);
    S.RainfedGreen=RG.Data./(RAH.Data./fma);
    S.IrrBlue=IB.Data./(IAH.Data./fma);
    S.RainfedBlue=RB.Data./(RAH.Data./fma);
    S.cropnumber=CropNo;
    S.cropname=crop;
    S.Note1='Green is rainwater';
    S.Note2='Blue is irrigation water';
    
    
    
    % special case, though for maize/sorghum/rye
    if numel(jj)==1
        
        S.IrrGreen=(IG.Data)./((IAH.Data+IAHfor.Data)./fma);
        S.RainfedGreen=RG.Data./((RAH.Data+RAHfor.Data)./fma);
        S.IrrBlue=IB.Data./((IAH.Data+IAHfor.Data)./fma);
        S.RainfedBlue=RB.Data./((RAH.Data+RAHfor.Data)./fma);
        S.cropnumber=CropNo;
        S.cropname=crop;
        S.Note1='Green is rainwater';
        S.Note2='Blue is irrigation water';
    
    end
    
    
    
    
end
%ANNUAL_CWU_IRC_GREEN_05_MM_C02_1998_2002.mat
%ANNUAL_CWU_IRC_GREEN_05_MM_C02_1998_2002

function  x=getcroplist
% List of crops for AH (area harvested) and YIELD (crops 1-29 irrigated, crops 30-58 in same order but rainfed):
x={ ...
    'Wheat','01','wheat',...
    'Maize for grain','02','maize',...
    'Rice ','03','rice',...
    'Barley ','04','barley',...
    'Rye for grain ','05','rye',...
    'Millet ','06','millet',...
    'Sorghum for grain ','07','sorghum',...
    'Soybeans ','08','soybean',...
    'Sunflower ','09','sunflower',...
    'Potatoes ','10','potato',...
    'Cassava ','11','cassava',...
    'Sugar cane ','12','sugarcane',...
    'Sugar beets ','13','sugarbeet',...
    'Oil palm ','14','oilpalm',...
    'Rapeseed / canola ','15','rapeseed',...
    'Groundnuts / Peanuts ','16','groundnuts',...
    'Pulses ','17','pulses',...
    'Citrus ','18','citrus',...
    'Date palm ','19','date',...
    'Grapes / vine ','20','grapes',...
    'Cotton ','21','cotton',...
    'Cocoa ','22','cocoa',...
    'Coffee ','23','coffee',...
    'Others perennial','24',' ',...
    'Managed grassland/pasture ','25','grassland ',...
    'Others annual','26',' ',...
    'Maize, forage ','27','maizefor',...
    'Rye, forage ','28','ryefor',...
    'Sorghum, forage ','29','sorghumfor'};