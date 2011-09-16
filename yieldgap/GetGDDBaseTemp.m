function T=GetGDDBaseTemp(crop)
% GetGDDBaseTemp return base GDD temperature as a string
%
%  example
%
%   GetGDDBaseTemp('maize')

persistent C

if isempty(C)
    C=ReadGenericCSV('croptype_NPK.csv',2);
end

iirow=strmatch(crop,C.CROPNAME,'exact');

if numel(iirow)==0
    % is this 'hi-income' or 'lo-income?'
    s=findstr(lower(crop),'loincome');
    if numel(s)==1
        redcrop=strrep(lower(crop),'loincome','');
        T=GetGDDBaseTemp(redcrop);
        return
    end
    
    s=findstr(lower(crop),'hiincome');
    if numel(s)==1
        redcrop=strrep(lower(crop),'hiincome','');
        T=GetGDDBaseTemp(redcrop);
        return
    end
    
    s=findstr(crop,'RF');
    if numel(s)==1
        redcrop=crop(1:end-4);
        T=GetGDDBaseTemp(redcrop);
        return
    end
    
    s=findstr(crop,'IRR');
    if numel(s)==1
        redcrop=crop(1:end-5);
        T=GetGDDBaseTemp(redcrop);
        return
    end
    
    T='0';
    warning(['found multiple (or zero) matches for cropname ' crop ' in ' mfilename]);
    return
    
end


T=num2str(C.GDD_Base_Temp(iirow));