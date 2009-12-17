function OutString=MakeSafeString(InString);
%MakeSafeString - make a string safe for being a fieldname

persistent NoColumnNameCounter
if isempty(NoColumnNameCounter)
    NoColumnNameCounter=0;
end

if isempty(InString);
    NoColumnNameCounter=NoColumnNameCounter+1;
    InString=['NoName' int2str(NoColumnNameCounter)];
end

if ~isempty(str2num(InString(1)))
    % 1st character is a number.  Prepend a "Val"
    InString=['Val' InString];
end

x=InString;
x=strrep(x,'/','_');
x=strrep(x,'\','_');
x=strrep(x,' ','');
x=strrep(x,'"','');
x=strrep(x,'=','_eq_');
OutString=x;

