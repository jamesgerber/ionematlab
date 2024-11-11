function faoname=ISOtoFAOName(ISO);
% ISOtoFAOName

persistent a

if isempty(a)
    a=readgenericcsv('FAO_CountryNameTable_Mar2020.txt',1,tab,1);
end

iidx = strcmp(ISO,a.ISO3);
faoname=a.Short_name{iidx};

