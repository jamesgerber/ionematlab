function varargout=bottomxlabel(m,n,o,string);
% BOTTOMXLABEL - draw a label on the x axis beneath the plot
%
% SYNTAX
% f=bottomxlabel(m,n,o,string) - if o>=n*(m-1)+1, write string onx-axis and
% return figure handle
h=[];

if o>= n*(m-1)+1
    h=xlabel(string);
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