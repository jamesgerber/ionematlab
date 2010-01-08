% MakeSoilFiles


%% Preliminaries

PE=ReadGenericCSV('WISEParameterEstimates.csv');
UC=ReadGenericCSV('WISEunitComposition.csv');
UC.PROP2=str2double(UC.PROP2);
UC.PROP3=str2double(UC.PROP3);
UC.PROP4=str2double(UC.PROP4);
UC.PROP5=str2double(UC.PROP5);
UC.PROP6=str2double(UC.PROP6);
UC.PROP7=str2double(UC.PROP7);
UC.PROP8=str2double(UC.PROP8);
UC.PROP9=str2double(UC.PROP9);
UC.PROP10=str2double(UC.PROP10);

S=OpenGeneralNetCDF('WISE5by5min.nc');
SoilIDMatrix=double(S(3).Data);

NewDataMatrix=SoilIDMatrix*0-9e9;
CorrectlySizedMatrix=ones(4320,2160)*(-99);
EmbeddingIndices=(73:1758);

SoilIDsInMap=unique(SoilIDMatrix);

TOTCMatrix=-999+0*SoilIDMatrix;
TOTNMatrix=-999+0*SoilIDMatrix;
BULKMatrix=-999+0*SoilIDMatrix;
TAWCMatrix=-999+0*SoilIDMatrix;
CLPCMatrix=-999+0*SoilIDMatrix;
SDTOMatrix=-999+0*SoilIDMatrix;
PHAQMatrix=-999+0*SoilIDMatrix;

%% Loop over every SUID.

for LayerNo=1:5;
    Layer=['D' int2str(LayerNo)];
    h=waitbar(0,['Working on Layer' Layer]);
    for j=1:numel(SoilIDsInMap);
        
        if round(j/25)==j/25
            waitbar(j/numel(SoilIDsInMap),h);
        end
        
        SUID=SoilIDsInMap(j);
        
        % for each SUID ...
        RowInUC=find(UC.SUID==SUID);
        
        % first find out how many soil types there are
        done=0;
        m=0;
        clear SoilPartStructure
        while ~done
            m=m+1;
            PROP=getfield(UC,['PROP' num2str(m)]);
            SOIL=getfield(UC,['SOIL' num2str(m)]);
            PRID=getfield(UC,['PRID' num2str(m)]);
            
            if isnan(PROP(RowInUC))
                done=1;
            else
                SoilPartStructure(m).PROP=PROP(RowInUC);
                SoilPartStructure(m).SOIL=SOIL(RowInUC);
                SoilPartStructure(m).PRID=PRID(RowInUC);
            end
            
        end
            
        SoilProps=SoilPartsToSoilProperties(SoilPartStructure,PE,Layer);
        %now have the SoilProps structure.  Put these data into the map in
        %the appropriate place.
        
        ii=find(SUID==SoilIDMatrix);
        
        TOTCMatrix(ii)=SoilProps.AvgTOTC;
        TOTNMatrix(ii)=SoilProps.AvgTOTN;
        BULKMatrix(ii)=SoilProps.AvgBULK;
      %  TAWCMatrix(ii)=SoilProps.AvgTAWC;
        CLPCMatrix(ii)=SoilProps.AvgCLPC;
        SDTOMatrix(ii)=SoilProps.AvgSDTO;
        PHAQMatrix(ii)=SoilProps.AvgPHAQ;

    end
    delete(h) %delete the waitbar
    
    % embed the Matrices
    % 
    [Long,Lat]=InferLongLat(CorrectlySizedMatrix);
    
    [RevNo,RevString,LastChangeRevNo,LCRString,AI]=GetSVNInfo;
    DAS.CodeRevisionNo=RevNo;
    DAS.CodeRevisionString=RevString; 
    DAS.LastChangeRevNo=LastChangeRevNo;
    DAS.ProcessingDate=datestr(now);
    
    TOTC=CorrectlySizedMatrix;
    TOTC(:,EmbeddingIndices)=TOTCMatrix;
    DAS.units='gC/kg';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(TOTC),['TOTC_Level' Layer],['TOTC_Level' Layer '.nc'],DAS); 
    
    TOTN=CorrectlySizedMatrix;
    TOTN(:,EmbeddingIndices)=TOTNMatrix;
    DAS.units='gN/kg';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(TOTN),'TOTN',['TOTN_Level' Layer '.nc'],DAS); 

    PHAQ=CorrectlySizedMatrix;
    PHAQ(:,EmbeddingIndices)=PHAQMatrix;
    DAS.units='PH';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(PHAQ),'PHAQ',['PHAQ_Level' Layer '.nc'],DAS); 

    BULK=CorrectlySizedMatrix;
    BULK(:,EmbeddingIndices)=BULKMatrix;
    DAS.units='te/m^3';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(BULK),'BULK',['BULK_Level' Layer '.nc'],DAS); 

    CLPC=CorrectlySizedMatrix;
    CLPC(:,EmbeddingIndices)=CLPCMatrix;
    DAS.units='Percentage';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(CLPC),'CLPC',['CLPC_Level' Layer '.nc'],DAS);    
end
  

%end

