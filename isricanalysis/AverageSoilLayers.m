c1=getdata('totc1',1);
c2=getdata('totc2',1);
c3=getdata('totc3',1);
c4=getdata('totc4',1);
c5=getdata('totc5',1);

b1=getdata('bulk1',1);
b2=getdata('bulk2',1);
b3=getdata('bulk3',1);
b4=getdata('bulk4',1);
b5=getdata('bulk5',1);

C=getdata('totc1');

LogicalCarbonSkip=(c1<0 | c2<0 | c3<0 | c4<0 | c5<0);
LogicalBulkSkip=(b1<0 | b2<0 | b3<0 | b4<0 | b5<0);


%%% AVERAGE THE CARBON

cd1=c1.*b1;   %carbon total gC/kg * kg/volume = gC /
	      %volume
cd2=c2.*b2;	      
cd3=c3.*b3;	      
cd4=c4.*b4;	      
cd5=c5.*b5;	      


%% find avg of all layers

cd_avg=[cd1+cd2+cd3+cd4+cd5]/5;
b_avg=[b1+b2+b3+b4+b5]/5;

c_avg=cd_avg./b_avg;

c_avg(LogicalBulkSkip | LogicalCarbonSkip)=-99;

Long=C.Long;
Lat=C.Lat;


clear DAS
    [RevNo,RevString,LastChangeRevNo,LCRString,AI]=GetSVNInfo;
    DAS.CodeRevisionNo=RevNo;
    DAS.CodeRevisionString=RevString; 
    DAS.LastChangeRevNo=LastChangeRevNo;
    DAS.ProcessingDate=datestr(now);
DAS.Long=C.Long;
DAS.Lat=C.Lat;
DAS.units=C.units;
DAS.source=C.source;
DAS.coderevisionno=C.coderevisionno;
DAS.Description='Average of top 100 cm';
WriteNetCDF(Long,Lat,c_avg,'Data','TOTC_avg.nc',DAS);


%%% find avg of top 30cm

cd30=[cd1+0.5*cd2]/1.5;
b30=[b1+0.5*b2]/1.5;

c30=cd30./b30;
c30(LogicalBulkSkip | LogicalCarbonSkip)=-99;
DAS.Description='Average of top 30 cm';
WriteNetCDF(Long,Lat,c30,'Data','TOTC_30.nc',DAS);


