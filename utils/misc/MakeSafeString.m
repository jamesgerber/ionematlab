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

if isequal(InString(1),' ') | isequal(InString(1),'_')
    OutString=MakeSafeString(InString(2:end));
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


tmp=str2num(InString(1));

if ~isempty(tmp)
   
    
    if isreal(tmp)
        % 1st character is a number.  Prepend a "Val"
         InString=['Val' InString]; 
    else
       % that first character is "i" or "j" ... that's not what we are
        % worried about.  do nothing.
    end
    
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

