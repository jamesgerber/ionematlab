function [cropname,Cropname,FAOCropName]=getFAOCropName(cropname);
% getFAOCropName
%
%  [cropname,Cropname,FAOCropName]=getFAOCropName(cropname);
cropname=lower(cropname);
Cropname=[upper(cropname(1)) cropname(2:end)];

FAOCropName=Cropname;

% special cases


switch cropname
    
    case 'oilpalm'
        
        FAOCropName='Oil palm fruit';
        
    case 'rice'
        FAOCropName='Rice, paddy';
        
        
    case 'sugarcane'
        FAOCropName='Sugar cane';
    case 'soybean'
        FAOCropName='Soybeans';
        
end
