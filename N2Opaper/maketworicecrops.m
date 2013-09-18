r=getdata('rice');
[mircadata] = getmircadata('rice', 'avgpercirr');


ricearea=r.Data(:,:,1);
ii=find(ricearea > 1e10);

irrarea=ricearea.*mircadata;
rfarea=ricearea.*(1-mircadata);

irrrice=r;
irrarea(ii)=9e20;

irrrice.Data(:,:,1)=irrarea;


rfrice=r;
rfarea(ii)=9e20;
rfarea(rfarea<0)=0;
rfrice.Data(:,:,1)=rfarea;



DAS=r;
DAS=rmfield(DAS,'Data');
DAS=rmfield(DAS,'Long');
DAS=rmfield(DAS,'Lat');
DAS.notes1='processed as part of N2O work.  Sep 6, 2013'
DAS.notes2='see maketworicecrops.m';

DAS.notes3='irrigated rice area by 75% criterion from mueller et al 2012';
WriteNetCDF(irrrice.Data,'Data','rice_irr75_5min',DAS);

DAS.notes3='rainfed rice area by 75% criterion from mueller et al 2012';
WriteNetCDF(rfrice.Data,'Data','rice_rf75_5min',DAS);

