function CropList=CropList(DirString,Year);
% CropList - return a list of crops
%
%  

if nargin  ==0
    DirString='';
end

if nargin ==2
    error('only have 2000')
end


a=dir([iddstring '/Crops2000/crops/*' DirString '*_5min.nc']);

for j=1:length(a)
    CropList{j}=strrep(a(j).name,'_5min.nc','');
end
