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
TOTCMatrix_median=-999+0*SoilIDMatrix;
TOTNMatrix=-999+0*SoilIDMatrix;
TOTNMatrix_median=-999+0*SoilIDMatrix;
BULKMatrix=-999+0*SoilIDMatrix;
BULKMatrix_median=-999+0*SoilIDMatrix;
TAWCMatrix=-999+0*SoilIDMatrix;
TAWCMatrix_modal=-999+0*SoilIDMatrix;
TAWCMatrix_median=-999+0*SoilIDMatrix;
CLPCMatrix_median=-999+0*SoilIDMatrix;
SDTOMatrix_median=-999+0*SoilIDMatrix;
PHAQMatrix_median=-999+0*SoilIDMatrix;
ECECMatrix_median=-999+0*SoilIDMatrix;
ELCOMatrix_median=-999+0*SoilIDMatrix;

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
        TOTCMatrix_median(ii)=SoilProps.MedianTOTC;
        TOTNMatrix(ii)=SoilProps.AvgTOTN;
        TOTNMatrix_median(ii)=SoilProps.MedianTOTN;

        BULKMatrix(ii)=SoilProps.AvgBULK;
                BULKMatrix_median(ii)=SoilProps.MedianBULK;

        TAWCMatrix(ii)=SoilProps.AvgTAWC;
        TAWCMatrix_modal(ii)=SoilProps.ModalTAWC;
        TAWCMatrix_median(ii)=SoilProps.MedianTAWC;
        CLPCMatrix_median(ii)=SoilProps.MedianCLPC;
        SDTOMatrix_median(ii)=SoilProps.MedianSDTO;
        PHAQMatrix_median(ii)=SoilProps.MedianPHAQ;
        ECECMatrix_median(ii)=SoilProps.MedianECEC;
        ELCOMatrix_median(ii)=SoilProps.MedianELCO;

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
    TOTC(:,EmbeddingIndices)=TOTCMatrix_median;
    DAS.units='gC/kg';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(TOTC),['TOTC_Level' Layer],['TOTC_Level' Layer '.nc'],DAS); 
    
    TOTN=CorrectlySizedMatrix;
    TOTN(:,EmbeddingIndices)=TOTNMatrix_median;
    DAS.units='gN/kg';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(TOTN),'TOTN',['TOTN_Level' Layer '.nc'],DAS); 

    PHAQ=CorrectlySizedMatrix;
    PHAQ(:,EmbeddingIndices)=PHAQMatrix_median;
    DAS.units='PH';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(PHAQ),'PHAQ',['PHAQ_Level' Layer '.nc'],DAS); 

    BULK=CorrectlySizedMatrix;
    BULK(:,EmbeddingIndices)=BULKMatrix_median;
    DAS.units='te/m^3';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(BULK),'BULK',['BULK_Level' Layer '.nc'],DAS); 

    CLPC=CorrectlySizedMatrix;
    CLPC(:,EmbeddingIndices)=CLPCMatrix_median;
    DAS.units='Percentage';
    DAS.source='ISRIC Version 1.0';
    WriteNetCDF(Long,Lat,single(CLPC),'CLPC',['CLPC_Level' Layer '.nc'],DAS);   
    
    TAWC=CorrectlySizedMatrix;
    TAWC(:,EmbeddingIndices)=TAWCMatrix;
    DAS.units='cm/m';
    DAS.source='ISRIC Version 1.0';
    DAS.Description=['Total Available Water Content. Weighted Average.' ...
        ' Layer ' Layer ];
    WriteNetCDF(Long,Lat,single(TAWC),'TAWC',['Avg_TAWC_Level' Layer '.nc'],DAS);
    
    TAWC=CorrectlySizedMatrix;
    TAWC(:,EmbeddingIndices)=TAWCMatrix_modal;
    DAS.units='cm/m';
    DAS.source='ISRIC Version 1.0';
    DAS.Description=['Total Available Water Content. Dominant Soil Type.' ...
        ' Layer ' Layer ];
    WriteNetCDF(Long,Lat,single(TAWC),'TAWC',['Modal_TAWC_Level' Layer '.nc'],DAS);
    
    TAWC=CorrectlySizedMatrix;
    TAWC(:,EmbeddingIndices)=TAWCMatrix_median;
    DAS.units='cm/m';
    DAS.source='ISRIC Version 1.0';
    DAS.Description=['Total Available Water Content. Dominant Soil Type.' ...
        ' Layer ' Layer ];
    WriteNetCDF(Long,Lat,single(TAWC),'TAWC',['Median_TAWC_Level' Layer '.nc'],DAS);
    
    ELCO=CorrectlySizedMatrix;
    ELCO(:,EmbeddingIndices)=ELCOMatrix_median;
    DAS.units='dS/m';
    DAS.source='ISRIC Version 1.0';
    DAS.Description=['Electrical conductivity. Dominant Soil Type.' ...
        ' Layer ' Layer ];
    WriteNetCDF(Long,Lat,single(ELCO),'ELCO',['Median_ELCO_Level' Layer '.nc'],DAS);
    
    ECEC=CorrectlySizedMatrix;
    ECEC(:,EmbeddingIndices)=ECECMatrix_median;
    DAS.units='cmol_c/kg';
    DAS.source='ISRIC Version 1.0';
    DAS.Description=['Effective Cation Exchange Capacity. Dominant Soil Type.' ...
        ' Layer ' Layer ];
    WriteNetCDF(Long,Lat,single(ECEC),'ECEC',['Median_ECEC_Level' Layer '.nc'],DAS);
    
end


%end

