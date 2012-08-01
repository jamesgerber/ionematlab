function varargout=leftylabel(m,n,o,string)
% LEFTYLABEL - draw a label on the y axis on the left side of the plot
%
% SYNTAX
% f=leftylabel(m,n,o,string) - if (o-1)/n is an integer, write string on the
% y-axis and return the figure handle
h=[];

if isint( (o-1)/n)
   h=ylabel(string);
end

if nargout==1
   varargout{1}=h;
end

function yes=isint(x)
if x==fix(x)
    yes=1;
else
    yes=0;
end