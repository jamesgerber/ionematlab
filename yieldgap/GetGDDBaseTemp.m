function T=GetGDDBaseTemp(crop)
% return base GDD temperature

persistent C

if isempty(C)
    C=readgenericcsv('croptype_NPK.csv',2);
end

iirow=strmatch(crop,C.CROPNAME,'exact');

if numel(iirow)~=1
   T='0';
   warning(['found multiple (or zero) matches for cropname ' crop ' in ' mfilename]);
   return
end


T=num2str(C.GDD_Base_Temp(iirow));