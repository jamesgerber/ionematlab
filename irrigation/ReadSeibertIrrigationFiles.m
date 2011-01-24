FileDir=[iddstring 'Irrigation/Seibert/Seibert_Irrigation_Jan2011_Raw/'];
wd=pwd;

a=dir([FileDir '/' '*_1998*.ASC']);

%ncols         4320
%nrows         2160
%xllcorner     -180
%yllcorner     -90
%cellsize      0.083333
%NODATA_value  -9



for j=1:length(a);
    %j=1
    
    ThisName=a(j).name
    
    b=dlmread([FileDir ThisName],' ',6,0);
    %end
    
    NewData=0*LandMaskLogical;
    
    
    % need to choose one of these lines
    NewData(1:4320,:)=b(:,1:4320)'; 
    
    ii=findstr(ThisName,'MM');
    MIRCACROPNo=str2num(ThisName(ii+ (4:5)));
    
    ii=find(ThisName=='.');
    
    NewName=ThisName(1:ii-1);
    
    
    NewFileName=['blahblahblah_MIRCACropCode' num2str(MIRCACROPNo) ...
        '.nc'];
    
    DAS.MissingDataValue=-9;
    DAS.DateProcessed=datestr(now)
    DAS.Notes='Do not distribute.';
    
    [Long,Lat]=InferLongLat(NewData);
    
    WriteNetCDF(Long,Lat,single(NewData),'Data',NewName,DAS);
    
    Data=single(NewData);
    
    save(NewName,'Data','ThisName','DAS')
    
    
end

