function [T,Tmax,redcrop]=GetGDDBaseTemp(crop)
% GetGDDBaseTemp return base GDD temperature as a string
%
%  example
%
%   GetGDDBaseTemp('maize')
%
%   [Tmin,Tmax]=GetGDDBaseTemp('maize')


Tmax='99';

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
        [T,Tmax]=GetGDDBaseTemp(redcrop);
        return
    end
    
    s=findstr(lower(crop),'hiincome');
    if numel(s)==1
        redcrop=strrep(lower(crop),'hiincome','');
        [T,Tmax]=GetGDDBaseTemp(redcrop);
        return
    end
    
    s=findstr(crop,'RF');
    if numel(s)==1
        %        redcrop=crop(1:end-4);
        redcrop=crop(1:s-1);
        [T,Tmax]=GetGDDBaseTemp(redcrop);
        return
    end
    
    s=findstr(crop,'IRR');
    if numel(s)==1
        %        redcrop=crop(1:end-5);
        redcrop=crop(1:s-1);
        [T,Tmax]=GetGDDBaseTemp(redcrop);
        return
    end
    
        s=findstr(crop,'_alt');
    if numel(s)==1
        redcrop=strrep(lower(crop),'_alt','');
        [T,Tmax]=GetGDDBaseTemp(redcrop);
        return
    end
    
    T='0';
    warning(['found multiple (or zero) matches for cropname ' crop ' in ' mfilename]);
    return
    
end


T=num2str(C.GDD_Base_Temp(iirow));


if nargout==2
    switch crop
        case 'maize'
            Tmax='30';
        case 'wheat'
            Tmax='25';
        case 'rice'
            Tmax='30';
        case 'maize_alt'
            Tmax='30';
            T='10';
        case 'rice_alt';
            Tmax='30';
            T='10';
    end
end

global JUSTIN_GDD
if isempty(JUSTIN_GDD)
    return
end

switch JUSTIN_GDD
    case 'Rev1'
        switch crop
            case 'maize'
                Tmax='30';
                T='10';
            case 'rice';
                Tmax='30';
                T='8';
        end
    otherwise
        warning('JUSTIN_GDD global flag not empty, but don''t know this value')

end

                
