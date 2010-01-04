function OutString=MakeSafeString(InString);
%MakeSafeString - make a string safe for being a fieldname
%
%   MakeSafeString(QUESTIONABLEFILENAME)
%
%    MakeSafeString
%
%    Example
%    MakeSafeString('Bad-FileName!')
%    MakeSafeString('5ReallyBadFileName\/ "-=This"')
%    MakeSafeString('')
%    MakeSafeString('')
%    clear MakeSafeString
%    MakeSafeString('')

% jsg  Dec 2009

if nargin==0
    help(mfilename)
    return
end

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
x=strrep(x,'!','');
x=strrep(x,'\','_');
x=strrep(x,'"','');
x=strrep(x,'=','_eq_');
x=strrep(x,'-','_');
x=strrep(x,' ','_');
OutString=x;

