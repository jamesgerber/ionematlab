function ReadSeibertIrrigationFiles(filename)
% ReadSeibertIrrigationFiles
%
%  reads .asc files with this header
%ncols         4320
%nrows         2160
%xllcorner     -180
%yllcorner     -90
%cellsize      0.083333
%NODATA_value  -9
%
%  syntax
%
%  ReadSeibertIrrigationFiles will open all .asc files in directory, save
%  as a .mat

if nargin==0
    a=dir('*.ASC');
    for j=1:length(a)
        a(j).name
        ReadSeibertIrrigationFiles(a(j).name);
    end
    a=dir('*.asc');
    for j=1:length(a)
        ReadSeibertIrrigationFiles(a(j).name);
    end
    return
end


b=dlmread([filename],' ',6,0);
%end

NewData=datablank;;

% b now has an extra line. (4321 instead of 4320)

% kate b and jamie g think that this is artefact of reading/writing
% different formats and it is the last line that doesn't correspond to
% anything physical. also, noted that for sugarcane there is consistent
% location along india border if we remove that final line.
% align

% so, just take the first 4320 of b.  also taking transpose
NewData(1:4320,:)=b(:,1:4320)';

% ii=findstr(ThisName,'MM');
% MIRCACROPNo=str2num(ThisName(ii+ (4:5)));

ii=find(filename=='.');

NewName=filename(1:ii-1);




DAS.MissingDataValue=-9;
DAS.DateProcessed=datestr(now)
DAS.Notes='Do not distribute.';

[Long,Lat]=InferLongLat(NewData);

WriteNetCDF(Long,Lat,single(NewData),'Data',NewName,DAS);
!gzip *.nc

Data=single(NewData);

save(NewName,'Data','filename','DAS')


return

%%%

%%%% script that was an earlier version of this


FileDir=[iddstring 'Irrigation/Seibert/Seibert_Irrigation_Jan2011_Raw/'];
wd=pwd;

a=dir([FileDir '/' 'YIELD*.ASC']);

%ncols         4320
%nrows         2160
%xllcorner     -180
%yllcorner     -90
%cellsize      0.083333
%NODATA_value  -9



for j=55:length(a);
    %j=1
    
    ThisName=a(j).name
    
    b=dlmread([FileDir ThisName],' ',6,0);
    %end
    
    NewData=0*LandMaskLogical;
    
    
    % need to choose one of these lines
    NewData(1:4320,:)=b(:,1:4320)';
    
    % ii=findstr(ThisName,'MM');
    % MIRCACROPNo=str2num(ThisName(ii+ (4:5)));
    
    ii=find(ThisName=='.');
    
    NewName=ThisName(1:ii-1);
    
    
    %  NewFileName=['blahblahblah_MIRCACropCode' num2str(MIRCACROPNo) ...
    %      '.nc'];
    
    DAS.MissingDataValue=-9;
    DAS.DateProcessed=datestr(now)
    DAS.Notes='Do not distribute.';
    
    [Long,Lat]=InferLongLat(NewData);
    
    WriteNetCDF(Long,Lat,single(NewData),'Data',NewName,DAS);
    
    Data=single(NewData);
    
    save(NewName,'Data','ThisName','DAS')
    
    
end

