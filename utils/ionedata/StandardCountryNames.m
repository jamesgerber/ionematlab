function varargout=StandardCountryNames(Input,NameForm,OutputForm);
% STANDARDCOUNTRYNAMES - determine standard country names
%
%  SYNTAX:
%      OUTPUT=STANDARDCOUNTRYNAMES(COUNTRYNAME) will attempt to
%      associate a unique country with COUNTRYNAME and return a
%      structure with all fields
%
%      OUTPUT=STANDARDCOUNTRYNAMES(COUNTRYNAME,NAMEFORM) will
%      attempt to associate a unique country with COUNTRYNAME but
%      only looking in the NAMEFORM field.
%  
%      OUTPUT=STANDARDCOUNTRYNAMES(COUNTRYNAME,NAMEFORM,OUTPUTFORM)
%      will return only a text value in the form OUTPUTFORM
%
%
%      Acceptable values for NAMEFORM are
%
%      'sagecountry' [default]
%      'sage3'
%      'ISO3'
%      'NAME_ISO'
%      'NAME_FAO'
%
%      Acceptable values for OutputForm are
%
%      'struct' [default]
%      'sagecountry' 
%      'sage3'
%      'ISO3'
%      'NAME_ISO'
%      'NAME_FAO'      
%
%    Example
%
%      StandardCountryNames('Bulgaria')
%      StandardCountryNames({'Bulgaria','France'})
%



    



fid=fopen('SCN_GADMandSAGEV10.txt');
C=textscan(fid,'%s%s%s%s%s%s%s%s%s','Delimiter',tab,'HeaderLines',2);
SageCountry=C{1};
SageRegion=C{2};
SageContinent=C{3};
SageCountryNoComma=C{4};
Sage3=C{5};
GADM_NAME_ENGLISH=C{6};
GADM_ISO=C{7};
GADM_NAME_ISO=C{8};
GADM_NAME_FAO=C{9};


if nargin<2
    MatchType='sagecountry';
else 
    MatchType=lower(NameForm);
end

if nargin<3
    if iscell(Input)
        OutputForm=MatchType;
    else
        OutputForm='struct';
    end
end

%%  if vector input, then call self recursively
if iscell(Input)
    switch lower(OutputForm)
        case {'struct','structure'}
            for j=1:length(Input)
                OS(j)=StandardCountryNames(Input{j},MatchType,'struct');
            end
            varargout{1}=OS;
        case {'sagecountry','sage3','iso3','name_iso','name_fao'}
             for j=1:length(Input)
                OC{j}=StandardCountryNames(Input{j},MatchType,OutputForm);
             end
             varargout{1}=OC;
    end
    return
end

    
    


switch MatchType
    case 'sagecountry'
        Row=GetRow(lower(Input),lower(SageCountry));
    case 'sage3'
        Row=GetRow(Input,Sage3);
    case 'ISO3'
        Row=GetRow(Input,GADM_ISO);
end


switch lower(OutputForm)
    case 'struct'
        OutputFieldName='';
    case 'sagecountry'
        OutputFieldName='SageCountry';
    case 'sage3'
        OutputFieldName='Sage3';
    case 'iso3'
        OutputFieldName='GADM_ISO';
    case 'name_iso'
        OutputFieldName='GADM_NAME_ISO';
     case 'name_fao'
        OutputFieldName='GADM_NAME_FAO';
           
        
end

if Row==-1
    OS.SageCountry='';
    OS.SageRegion='';
    OS.SageContinent='';
    OS.SageCountryNoComma='';
    OS.Sage3='';
    OS.GADM_NAME_ENGLISH='';
    OS.GADM_ISO='';
    OS.GADM_NAME_ISO='';
    OS.GADM_NAME_FAO='';
else  
    OS.SageCountry=SageCountry{Row};
    OS.SageRegion=SageRegion{Row};
    OS.SageContinent=SageContinent{Row};
    OS.SageCountryNoComma=SageCountryNoComma{Row};
    OS.Sage3=Sage3{Row};
    OS.GADM_NAME_ENGLISH=GADM_NAME_ENGLISH{Row};
    OS.GADM_ISO=GADM_ISO{Row};
    OS.GADM_NAME_ISO=GADM_NAME_ISO{Row};
    OS.GADM_NAME_FAO=GADM_NAME_FAO{Row};
end

switch lower(OutputForm)
 case {'struct','structure'}
  varargout{1}=OS;
    otherwise 
     varargout{1}=getfield(OS,OutputFieldName);
end



function Row=GetRow(Input,List)
%% GetRow

if length(Input)==0
    error
end

% first see if there is an exact and unique match

Row=strmatch(Input,List,'exact');
if length(Row)==1
    return
end

if length(Row)>1
    switch(Input(1:min(6,end)))
        case 'israel'
            Row=Row(1);
            return
        case 'serbia'
            Row=Row(2);
            return
        otherwise
            
            error(['found two exact matches.  problem with input files.'])
    end
end

% now remove constraint of exactness
Row=strmatch(Input,List);
if length(Row)==1
    return
end

%
%if length(Row)==0
%    Row=GetRow(Input(1:end-1),List);
%    return
%end

if length(Row)>1
    error(['Ambiguous.']);
end

if length(Row)==0
    % didn't find any matches.  lets return a null
    Row=-1;
end
    
    
    
    
    
    

% now


%%  