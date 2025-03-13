function [cropname,Cropname,FAOCropName]=getFAOCropName2024(cropname);
% getFAOCropName
%
%  [FAOCropName]=getFAOCropName(cropname);
%
%
%  Dangerous overloaded bad-programming syntax
%  [cropname,Cropname,FAOCropName]=getFAOCropName(cropname);
    

if nargin==0
    help(mfilename)
    return
end


persistent  Group Cropname_FAO Cropname_monfreda itemcode;
if isempty(itemcode)
    fid=fopen([iddstring '/misc/Reconcile_Monfreda_FAO_cropnames.txt']);
    C=textscan(fid,'%s%s%s%s','Delimiter',tab);
    fclose(fid);
    itemcode=C{1};
    Cropname_monfreda=C{2};
    Cropname_FAO=C{3};
    Group=C{4};
    
    if ~isequal(Group{1},'GROUP')
        error([' problem with Reconcile_Monfreda_FAO_cropnames'])
    end
    if ~isequal(Cropname_FAO{1},'Cropname_FAO')
        error([' problem with Reconcile_Monfreda_FAO_cropnames'])
    end
    if ~isequal(Cropname_monfreda{1},'CROPNAME_monfreda')
        error([' problem with Reconcile_Monfreda_FAO_cropnames'])
    end
    if ~isequal(itemcode{1},'ITEM_CODE')
        error([' problem with Reconcile_Monfreda_FAO_cropnames'])
    end
    Group=Group(2:end);
    Cropname_FAO=Cropname_FAO(2:end);
    Cropname_monfreda=Cropname_monfreda(2:end);
    itemcode=itemcode(2:end);
end

idx=strmatch(cropname,Cropname_monfreda,'exact');
FAOCropName=Cropname_FAO{idx};

cropname=lower(cropname);
Cropname=[upper(cropname(1)) cropname(2:end)];

FAOCropName=strrep(FAOCropName,'"','');


FAOCropName=[upper(FAOCropName(1)) lower(FAOCropName(2:end))];
    

switch FAOCropName
    case 'Citrus fruit, total'
        FAOCropName='Citrus Fruit, Total'                         ;
    case 'Anise, badian, fennel, corian.'
        FAOCropName='Anise, badian, fennel, coriander';
    case 'Citrus fruit, nes'
        FAOCropName='Fruit, citrus nes';
    case 'Pulses, nes'
        FAOCropName='Pulses nes';

end


switch cropname


    case 'groundnut'
        FAOCropName='Groundnuts, excluding shelled';
        
    case 'cotton'
        FAOCropName='Seed cotton, unginned';
    
    case 'oilpalm'
        
        FAOCropName='Oil palm fruit';
        
    case 'rice'
        FAOCropName='Rice, paddy';
        
        
    case 'sugarcane'
        FAOCropName='Sugar cane';
    case 'soybean'
        FAOCropName='Soybeans';
    case 'areca'
        FAOCropName='Areca nuts';
    case 'cerealnes'
        FAOCropName='Cereals nes';
    case 'chestnut'
        FAOCropName='Chestnut';
   case 'cinnamon'
        FAOCropName='Cinnamon (cannella)';
   case 'cocoa'
        FAOCropName='Cocoa, beans';
   case 'fruitnes'
        FAOCropName='Fruit, fresh nes';
   case 'kolanut'
        FAOCropName='Kola nuts';
   case 'maizefor'
       FAOCropName='Maize, green';
    case 'mate'
        FAOCropName='Maté';
    case 'nutnes'
        FAOCropName='Nuts nes';
    case 'oilseedsnes'
        FAOCropName='Oilseeds nes';
    case 'greenonion'
        FAOCropName='Onions, shallots, green' ;
        
   case 'melonetc'
        FAOCropName='Melons, other (inc.cantaloupes)';
   case 'plantain'
        FAOCropName='Plantains and others';
   case 'pulsesnes'
        FAOCropName='Pulses, nes';
   case 'pyrethrum'
        FAOCropName='Pyrethrum, dried';
   case 'rootnes'
        FAOCropName='Roots and tubers nes';
   case 'spicenes'
        FAOCropName='Spices nes';
   case 'sugarnes'
        FAOCropName='Sugar crops nes';
   case 'tangetc'
        FAOCropName='Tangerines, mandarins, clementines, satsumas';
   case 'vegetablenes'
        FAOCropName='Vegetables, fresh nes';
   case 'chestnut'
        FAOCropName='Chestnut';
    case 'sourcherry'
        FAOCropName='Cherries, sour';
      case 'stonefruitnes'
        FAOCropName='Fruit, stone nes';   
     case 'chestnut'
        FAOCropName='Chestnut';
    case 'rubber'
        FAOCropName='Rubber, natural';
    case 'oilseednes'
        FAOCropName='Oilseeds nes';
    case 'mixedgrain'
        FAOCropName='Grain, mixed';
    case 'groundnut'
        FAOCropName='Groundnuts, excluding shelled';

        
        
end

% section to get to 2024 names
persistent CPD CPDold
if isempty(CPD)
    [CPD,verstring]=ReturnProductionData;
    CPD=subsetofstructureofvectors(CPD,strmatch('World',CPD.Area));
    CPD=subsetofstructureofvectors(CPD,strmatch('Production',CPD.Element));
    dpd=DataProductsDir;
    CPDold=readgenericcsv([dpd '/ext/FAOstat/Production/March18_2021_RevE/Production_Crops_Livestock_E_All_Data_Normalized/Production_Crops_Livestock_E_All_Data_Normalizednq.txt'],1,tab,1);
        
    CPDold=subsetofstructureofvectors(CPDold,strmatch('World',CPDold.Area));
    CPDold=subsetofstructureofvectors(CPDold,strmatch('Production',CPDold.Element));

end
idx=strmatch(FAOCropName,CPDold.Item);
if numel(idx)>0
    CPDold.Item_Code(idx(1));

    jdx=find(CPD.Item_Code==CPDold.Item_Code(idx(1)));
    if numel(jdx)==0
            FAOCropName='';
    else
        FAOCropName=CPD.Item{jdx(1)};
    end
else
    FAOCropName='';
end




if nargout<2
    cropname=FAOCropName;
end


