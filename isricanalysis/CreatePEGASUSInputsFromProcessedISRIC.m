%% Modal - most frequently occuring soil typ
[Long,Lat,wc1]=OpenNetCDF('Modal_TAWC_LEVELD1.nc');
[Long,Lat,wc2]=OpenNetCDF('Modal_TAWC_LEVELD2.nc');
[Long,Lat,wc3]=OpenNetCDF('Modal_TAWC_LEVELD3.nc');
[Long,Lat,wc4]=OpenNetCDF('Modal_TAWC_LEVELD4.nc');
[Long,Lat,wc5]=OpenNetCDF('Modal_TAWC_LEVELD5.nc');


%need to create the following:
%awc1 - available water capacity: 0 to 50
%awc2 - 50 to 150
%awc20 - 0 - 20
%
%awc1= (wc1+wc2+(1/2)wc3)*N
%
%awc2= ((0.5)wc3+1*wc4+3.5*wc5)*N
%
%awc20=wc1*N;

%N=2.    This can be thought of 0.2m (to go from cm/m to cm of
%water capacity ISRIC awc data given in terms of cm/m.  ) and then
%multiplication by 10 (to go from cm to mm) 

awc1=(wc1+wc2+0.5*wc3)*2.0;
awc2=(.5*wc3+wc4+3.5*wc5)*2.0;
awc20=wc1*2.0;
 DAS.Description='awc1:  Most common soil-type available Water Capacity (in mm) 0 to 50 cm'
 DAS.Notes='ISRIC Data.  Processed July 15, 2010';
 DAS.Units='mm'
 WriteNetCDF(awc1,'awc1','awc1_modal.nc',DAS);

 DAS.Description='awc2:  Most common soil-type available Water Capacity (in mm) 50 to 150 cm'
 DAS.Notes='ISRIC Data.  Processed July 15, 2010';
 DAS.Units='mm';
 WriteNetCDF(awc2,'awc2','awc2_modal.nc',DAS);

 
 DAS.Description='awc20:  Most common soil-type available Water Capacity (in mm) 0 to 20 cm'
 DAS.Notes='ISRIC Data.  Processed July 15, 2010';
 WriteNetCDF(awc20,'awc20','awc20_modal.nc',DAS);
 
 %% Average
 
[Long,Lat,wc1]=OpenNetCDF('Avg_TAWC_LEVELD1.nc');
[Long,Lat,wc2]=OpenNetCDF('Avg_TAWC_LEVELD2.nc');
[Long,Lat,wc3]=OpenNetCDF('Avg_TAWC_LEVELD3.nc');
[Long,Lat,wc4]=OpenNetCDF('Avg_TAWC_LEVELD4.nc');
[Long,Lat,wc5]=OpenNetCDF('Avg_TAWC_LEVELD5.nc');


%need to create the following:
%awc1 - available water capacity: 0 to 50
%awc2 - 50 to 150
%awc20 - 0 - 20
%
%awc1= (wc1+wc2+(1/2)wc3)*N
%
%awc2= ((0.5)wc3+1*wc4+3.5*wc5)*N
%
%awc20=wc1*N;

%N=2.    This can be thought of 0.2m (to go from cm/m to cm of
%water capacity ISRIC awc data given in terms of cm/m.  ) and then
%multiplication by 10 (to go from cm to mm) 

awc1=(wc1+wc2+0.5*wc3)*2.0;
awc2=(.5*wc3+wc4+3.5*wc5)*2.0;
awc20=wc1*2.0;
 DAS.Description='awc1:  Soil-type averaged available Water Capacity (in mm) 0 to 50 cm'
 DAS.Notes='ISRIC Data.  Processed July 15, 2010';
 DAS.Units='mm'
 WriteNetCDF(awc1,'awc1','awc1_avg.nc',DAS);

 DAS.Description='awc2:  Soil-type averaged available Water Capacity (in mm) 50 to 150 cm'
 DAS.Notes='ISRIC Data.  Processed July 15, 2010';
 DAS.Units='mm';
 WriteNetCDF(awc2,'awc2','awc2_avg.nc',DAS);

 
 DAS.Description='awc20:  Soil-type averaged available Water Capacity (in mm) 0 to 20 cm'
 DAS.Notes='ISRIC Data.  Processed July 15, 2010';
 WriteNetCDF(awc20,'awc20','awc20_avg.nc',DAS);