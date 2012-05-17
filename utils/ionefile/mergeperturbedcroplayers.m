function mergeperturbedcroplayers(cropname,NewArea,NewYield,Year,DAS);
% mergeperturbedcroplayers - combines area / yield into a new data layer

if nargin < 5
    DAS=struct;
end

S=getdata(cropname);
DAS.missing_value=S.missing_value;
S.Data(:,:,1)=NewArea;
S.Data(:,:,2)=NewYield;


DAS.Description=['Perturbed crop data for ' int2str(Year) ];
DAS.BaseYear='2000';

NewFileName=[cropname '_5min_Y' int2str(Year) ];

writenetcdf(S.Long,S.Lat,S.Data,'cropdata',NewFileName,DAS);


return


a=dir('Y*nc')
for j=1:length(a)
    tmp=a(j).name;
    thiscrop=tmp(6:end-3)
    
    areafile=opennetcdf(['Hectare2005' thiscrop]);
    yieldfile=opennetcdf(a(j).name);
    DAS.origfiledate=a(j).date;
    DAS.areaversion=areafile.version;
    DAS.yieldversion=yieldfile.version;
    mergeperturbedcroplayers(thiscrop,areafile.Data,yieldfile.Data,2005);
end


thiscrop='wheat'
areafile=opennetcdf('Global_Wheat_2005_area_withperturb_Jan2011.nc');
yieldfile=opennetcdf('Global_Wheat_2005_yield_withperturb_Jan2011_updated.nc');
DAS.areaversion=areafile.version;
DAS.yieldversion=yieldfile.version;
mergeperturbedcroplayers(thiscrop,areafile.Data,yieldfile.Data,2005);

    
thiscrop='soybean'
areafile=opennetcdf('Global_Soybean_2005_area_withperturb_Jan2011.nc');
yieldfile=opennetcdf('Global_Soybean_2005_yield_withperturb_Jan2011.nc');
DAS.areaversion=areafile.version;
DAS.yieldversion=yieldfile.version;
mergeperturbedcroplayers(thiscrop,areafile.Data,yieldfile.Data,2005);

thiscrop='rice';
areafile=opennetcdf('Global_Rice_2005_area_withperturb_Jan2011.nc');
yieldfile=opennetcdf('Global_Rice_2005_yield_withperturb_Jan2011.nc');
DAS.areaversion=areafile.version;
DAS.yieldversion=yieldfile.version;
mergeperturbedcroplayers(thiscrop,areafile.Data,yieldfile.Data,2005);

thiscrop='maize';
areafile=opennetcdf('Maize_2005_area_withperturb.nc');
yieldfile=opennetcdf('Global_Maize_2005_yield_withperturb_Jan2011.nc');
DAS.areaversion=areafile.version;
DAS.yieldversion=yieldfile.version;
mergeperturbedcroplayers(thiscrop,areafile.Data,yieldfile.Data,2005);

