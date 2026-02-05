function     [aSRBret, aMNEret, aXKOret]=getSMNareas(cropname);


persistent aSRB aMNE aXKO

if isempty(aSRB)

    [CPDfull,verstring]=ReturnProductionData;
    yr=2006;
    FAOCropName=getFAOCropName(cropname);
    idx=strmatch(FAOCropName,CPDfull.Item,'exact');
    CPD=subsetofstructureofvectors(CPDfull,idx);

    
    idx=find(CPD.Year>=(yr) & CPD.Year<=(yr));
    CPD=subsetofstructureofvectors(CPD,idx);
    
    
    idx=strmatch('Area',CPD.Element)
    CPD=subsetofstructureofvectors(CPD,idx);

    
    FAOCode=SAGE3ToFAOCode('SRB',yr);
    idx=find(CPD.Area_Code==FAOCode);    
    aSRB=CPD.Value(idx);
    if isempty(aSRB)
        aSRB=nan;
    end
    
      FAOCode=SAGE3ToFAOCode('MNE',yr);
    idx=find(CPD.Area_Code==FAOCode);    
    aMNE=CPD.Value(idx);
    if isempty(aMNE)
        aMNE=nan;
    end  
    
     FAOCode=SAGE3ToFAOCode('XKO',yr);
    idx=find(CPD.Area_Code==FAOCode);    
    aXKO=CPD.Value(idx);
    if isempty(aXKO)
        aXKO=nan;
    end
    
    
    
end
   
aSRBret=aSRB;
aMNEret=aMNE;
aXKOret=aXKO;