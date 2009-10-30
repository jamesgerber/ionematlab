function varargout=leftylabel(m,n,o,string);

h=[];

if o>= n*(m-1)+1
    h=xlabel(string);
end

if nargout==1
   varargout{1}==h;
end

function yes=isint(x)
if x==fix(x)
    yes=1;
else
    yes=0;
end