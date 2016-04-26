function Integer=ASCII2Integer(str);
% ASCII2Integer - turn a string into a unique integer. 
%
%   Syntax
%
%   ASCII2Integer(string)
%
%   Will return a unique integer.  string can only be about 7 characters
%   long.

if ~ischar(str)
    % it's not a string.  let's accept a cell array.
    if iscell
        error(['need code to handle a cell array']);
    else
        error(['This doesn''t appear to be a string or a cell array of' ...
            ' strings']);
    end
end

LookupVector=char(0:255);

HexExpression='a';  %make sure it is a character, otherwise the following
%gets screwed up

for j=1:length(str)
    ii=findstr(str(j),LookupVector);
    HexVal=dec2hex(ii);
    HexExpression([2*j-1 2*j])=HexVal(1:2);
end

Integer=uint64(hex2dec(HexExpression));
if Integer == uint64(1e90)
    error('Overflow in ASCII2Integer')
end