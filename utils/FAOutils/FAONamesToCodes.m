function Codes=FAONamesToCodes(countrynamelist,codefield);
%  FAONamesToCodes
%
%  Syntaxes
%
%   CodeList=FAONamesToCodes(countrynamelist,codefield)  returns a list of codes
%
%   CodeList=FAONamesToCodes(countrynumlist,codefield)  returns a list of codes
%   Codes=FAONamesToCodes;  % returns a table with fields
%     'Short_name'
%     'Official_name'
%     'ISO3'
%     'ISO2'
%     'UNI'
%     'UNDP'
%     'FAOSTAT'
%     'GAUL'
%
%

persistent a

if isempty(a)
    a=readgenericcsv('FAO_CountryNameTable_Mar2020.txt',1,tab,1);
end



if nargin==0
    Codes=a;
    return
end


if nargin==1
    error('no syntax for this yet')
end


if iscell(countrynamelist)
    if numel(countrynamelist)==1
        countrynamelist={char(countrynamelist)};  % this forces it to be a char inside a cell array
    end
elseif isnumeric(countrynamelist)
    % numeric, do nothing
else
    countrynamelist={char(countrynamelist)};
end

codelist=getfield(a,codefield);

if isnumeric(countrynamelist)
    % these are numbers
    countrynumberlist=countrynamelist;
    
    for jnum=1:numel(countrynumberlist);
        
        idx=find(countrynumberlist(jnum)==[a.FAOSTAT]);
        if numel(idx)==1
            codelistoutput(jnum)=codelist(idx);
        else
            codelistoutput(jnum)=-1;
            disp(['did not find a match for ' int2str(countrynumberlist(jnum)) ])
        end
        
    end
    
else
    % these are names
    for jname=1:numel(countrynamelist)
        
        thisname=countrynamelist{jname};
        idxshort=strmatch(thisname,a.Short_name,'exact');
        idxofficial=strmatch(thisname,a.Official_name,'exact');
        
        % did either match?
        
        if numel(idxshort)==1
            codelistoutput(jname)=codelist(idxshort);
        elseif  numel(idxofficial)==1
            codelistoutput(jname)=codelist(idxofficial);
        else
            codelistoutput(jname)={''};
            disp(['did not find a match for ' thisname ])
        end
        
    end
    
end


if isnumeric(codelist)
    Codes=codelistoutput;
    return
end

if isnumeric(codelistoutput)
    Codes=codelistoutput;
    return
end

if numel(codelistoutput)==1
    Codes=codelistoutput{1};
else
    Codes=codelistoutput;
end











% pre-processing notes
% did a text capture of this page from FAO:
%  http://www.fao.org/countryprofiles/iso3list/en/
%  saving .csv with this file
%csv2tabdelimited FAO_CountryNameTable.csv FAO_CountryNameTable_Mar2020.txt
