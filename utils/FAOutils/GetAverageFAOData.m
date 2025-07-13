function [AverageYield,AverageArea,CPDfull]=GetAverageFAOData(SAGE3,cropname,~,yr,AlignPlusMinus);
% GetAverageFAOData - return FAO Data with window average
%
% [AverageYield,AverageArea,CPDfull]=GetAverageFAOData(SAGE3,cropname,~,yr,AlignPlusMinus);


 if nargin==0
     help(mfilename)
     return
 end
 

if numel(yr)>1
    
    for j=1:numel(yr)
    [ay(j),aa(j)]=GetAverageFAOData(SAGE3,cropname,0,yr(j),AlignPlusMinus);
    end
    AverageYield=(ay);
    AverageArea=(aa);
    ay
    aa
    return
end



[CPDfull,verstring]=ReturnProductionData;
%[gadmgeo, sagegeo] = getgeo;

%limit to country
SAGE3;

if isequal(lower(SAGE3),'world')
   FAOCode=5000;
else
    try
        FAOCode=SAGE3ToFAOCode(SAGE3,yr);
    catch
        AverageYield=nan;
        AverageArea=nan;
        return
    end
end

if isempty(FAOCode)
    AverageYield=nan;
    AverageArea=nan;
    return
    
end





idx=find(CPDfull.Area_Code==FAOCode);
CPD=subsetofstructureofvectors(CPDfull,idx);

% limit to crop
FAOCropName2018=getFAOCropName(cropname);
FAOCropName2024=getFAOCropName2024(cropname);


switch FAOCropName2018
    case 'Maize'
        FAOCropName2023='Maize (corn)';
    case 'Rice, paddy'
        FAOCropName2023='Rice';
    case 'Rapeseed'
         FAOCropName2023='Rape or colza seed';
    case 'Soybeans'
        FAOCropName2023='Soya beans';
    case 'Cassava';
        FAOCropName2023='Cassava, fresh';
    case 'Groundnuts, with shell'
        FAOCropName2023='Groundnuts, excluding shelled';
    case 'Almonds, with shell'
        FAOCropName2023='Almonds, in shell'; 
    case 'Anise, badian, fennel, coriander' 
        FAOCropName2023='Anise, badian, coriander, cumin, caraway, fennel and juniper berries, raw';
    case 'Agave fibres nes'
        FAOCropName2023='Agave fibres, raw, n.e.c.';
    case 'Roots and tubers nes'
        FAOCropName2023='Roots and Tubers, Total';

  case 'Flax fibre and tow'
         FAOCropName2023='Flax, raw or retted'
%  case ''
%         FAOCropName2023='Mushrooms and truffles'
%  case ''
%         FAOCropName2023='Coconuts, in shell'
% 
%          case ''
%         FAOCropName2023=
% 
% 'Citrus Fruit, Total'
% 
    case 'Cereals nes'
        FAOCropName2023='Cereals n.e.c.'
    otherwise 
        Name2023=FAO2023Names(FAOCropName2018);
        FAOCropName2023=Name2023;
end


% Cycle through the cropnames ... do any of them match?

idx=find(strcmp(CPD.Item,FAOCropName2023));

if isempty(idx)
    idx=find(strcmp(CPD.Item,FAOCropName2024));
    if isempty(idx)
        idx=find(strcmp(CPD.Item,FAOCropName2018));
        if isempty(idx)
            disp(['no FAO Data for ' cropname ' in ' SAGE3 ]);
        end
    end
end

CPD=subsetofstructureofvectors(CPD,idx);




%limit to years around yr
Nyears=AlignPlusMinus;
idx=find(CPD.Year>=(yr-AlignPlusMinus) & CPD.Year<=(yr+AlignPlusMinus));
CPD=subsetofstructureofvectors(CPD,idx);


% get yield values

idxy=strmatch('Yield',CPD.Element);

YieldValues=CPD.Value(idxy);
YieldYearValues=CPD.Year(idxy);

idxa=strmatch('Area',CPD.Element);
AreaValues=CPD.Value(idxa);
AreaYearValues=CPD.Year(idxa);

%% aie!  why are we here?  Is this a country that didn't exist in the year we are talking about


persistent aSRB aMNE aXKO

if isempty(aSRB)
    [aSRB, aMNE, aXKO]=getSMNareas(cropname);
end

switch SAGE3
    
    case {'SRB','MNE'}
        FAOCode=SAGE3ToFAOCode('SMN');
        
        
        idx=find(CPDfull.Area_Code==FAOCode);
        CPD=subsetofstructureofvectors(CPDfull,idx);
        
        % limit to crop
        FAOCropName=getFAOCropName(cropname);
        idx=strmatch(FAOCropName,CPD.Item,'exact');
        CPD=subsetofstructureofvectors(CPD,idx);
        
        %limit to years around yr
        Nyears=AlignPlusMinus;
        idx=find(CPD.Year>=(yr-AlignPlusMinus) & CPD.Year<=(yr+AlignPlusMinus));
        CPD=subsetofstructureofvectors(CPD,idx);
        
        
        % get yield values
        
        idxy=strmatch('Yield',CPD.Element);
        
        YieldValues=CPD.Value(idxy);
        
        idxa=strmatch('Area',CPD.Element);
        AreaValues=CPD.Value(idxa);
        
        
        % now assign areas according to 2006 area
        

        
        y=YieldValues;
        a=AreaValues;
        try
            ii=isfinite(y.*a);
            AverageYield= sum(y(ii).*a(ii))./sum(a(ii))/1e4;
            AverageArea=mean(a(ii));
        catch
            
            disp(['Issue for ' cropname ' in ' SAGE3])
            AverageYield=nan;
            AverageArea=nan;
        end
        
        AverageYield=AverageYield;
        
        
        switch SAGE3
            case 'SRB'
                AverageArea=AverageArea.*aSRB/nansum(aSRB+aMNE);
            case 'MNE'
                AverageArea=AverageArea.*aMNE/nansum(aSRB+aMNE);
            otherwise
                error('how did we get here? ')
        end
        
        %   disp([' allocating pre-2006 SMN onto ' SAGE3 ]);
        return
end  

if numel(idxa)==0 | numel(idxy)==0
    
    AverageYield=nan;
    AverageArea=nan;
    return
end
        
% What are proper units

switch CPD.Unit{idxy(1)}
    case 'kg/ha'
        FAOYIELDTOTONSPERHA=1000;
    case 'hg/ha'
        FAOYIELDTOTONSPERHA=10000;
    otherwise
        error
end

y=YieldValues;
a=AreaValues;
try
    
    ii=isfinite(y.*a);
    
    % AverageYield= sum(YieldValues.*AreaValues)./sum(AreaValues);
    % AverageArea=mean(AreaValues);
    %
    
    AverageYield= sum(y(ii).*a(ii))./sum(a(ii))/FAOYIELDTOTONSPERHA;
    AverageArea=mean(a(ii));
catch
    
    if numel(y)==0 | numel(a)==0
           disp(['Issue for ' cropname ' in ' SAGE3])
           AverageYield=nan;
           AverageArea=nan;
           return
    end
    
    goodyears=intersect(AreaYearValues,YieldYearValues);
    
    clear a y
    for j=1:numel(goodyears)
        idx=find(AreaYearValues==goodyears(j));
        a(j)=AreaValues(idx);
        idx=find(YieldYearValues==goodyears(j));
        y(j)=YieldValues(idx);
    end
    
    
     ii=isfinite(y.*a);
    
    % AverageYield= sum(YieldValues.*AreaValues)./sum(AreaValues);
    % AverageArea=mean(AreaValues);
    %
    
    AverageYield= sum(y(ii).*a(ii))./sum(a(ii))/FAOYIELDTOTONSPERHA;
    AverageArea=mean(a(ii));
    
    
    if isempty(AverageYield) | isempty(AverageArea)
        AverageYield=nan;
        AverageArea=nan;
    end
    
    
    

end
    
return

%% code to test
cn=cropnames;
for j=1:175;
    clear a


    a(1)=GetAverageFAOData('USA',cn{j},0,2000,0);
    a(2)=GetAverageFAOData('BRA',cn{j},0,2000,0);
    a(3)=GetAverageFAOData('CHN',cn{j},0,2000,0);
    
    if numel(find(isfinite(a)))==0
        cn{j}
        keyboard
    else
        disp(['found some data for ' cn{j}]);
    end

end

    

    