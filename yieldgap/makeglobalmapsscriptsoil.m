
%TitleStr=


% make Global Map script with reference to soil type

[Long,Lat,SQI]=OpenNetCDF('~/sandbox/jsg_018_HarmonisedWorldSoilDatabase/HWSD_CompositeSQI.nc');

for j=1:3
    switch j
        case 3
            CSQI=(SQI <=1 & SQI > .9);
        case 2
            CSQI=(SQI <=.9 & SQI > .6);
        case 1
            CSQI=(SQI <=.6 & SQI > 0);    
    end
    LogicalArray=double(CSQI);
LogicalArray(LogicalArray==0)=NaN;

    titlestr=([cropname 'Yield Gap. ' Nstr 'x' Nstr '. Moisture index=' ...
        WetFlag '. GDD Base Temp=' GDDTempstr '.  Rev' Rev '. CSQI=' num2str(j)]);

    ThinSurf(Long,Lat,YieldGapArray.*LogicalArray,'Yield Gap',titlestr);
    
end
