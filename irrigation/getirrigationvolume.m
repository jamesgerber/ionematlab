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
    AH=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/AH_CROP'...
        CropNo '.mat']);
    S.area=AH.Data;
    Y=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'YIELD_CROP'  CropNo '_1998_2002.mat']);
    S.yield=AH.Data;
    
    
    
    IG=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_IRC_GREEN_05_MM_C'  CropNo '_1998_2002.mat']);
    
    RG=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_RFC_GREEN_05_MM_C'  CropNo '_1998_2002.mat']);
    
    IB=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_IRC_BLUE_05_MM_C'  CropNo '_1998_2002.mat']);
    
    RB=load([iddstring '/Irrigation/WaterUsage/processed_matfiles/'...
        'ANNUAL_CWU_RFC_BLUE_05_MM_C'  CropNo '_1998_2002.mat']);


    S.IrrGreen=IG.Data;
    S.RainfedGreen=RG.Data;
    S.IrrBlue=IB.Data;
    S.RainfedBlue=RB.Data;
    S.cropnumber=CropNo;
    S.cropname=crop;
    
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
    'Potatoes ','10','potatoes',...
    'Cassava ','11','cassava',...
    'Sugar cane ','12','sugarcane',...
    'Sugar beets ','13','sugarbeets',...
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