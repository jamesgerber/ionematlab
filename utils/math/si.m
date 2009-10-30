function [si]=si(xx);
% function [si]=si(x);
%  computes Sine Integral
%           /x
%  si(x) =  |  sin(t)/t dt
%           /0 
%
% See Numerical Recipies for small x, large x algorithms
%
% Beware the many different conventions for defining this function
%
%  James Gerber
%  UCSC Physics
%  August 1998

for mm=1:length(xx)

x=xx(mm);

if x==0 
  si(mm)=0;
elseif x<3
  temp=0;
  for j=1:2:14;
  temp=temp+ x.^j/(j*prod(1:j))*(-1)^((j-1)/2);
  end;
  si(mm)=temp;
elseif x> 12

 t1=0;
 t2=0;
 for j=0:12;
  t1=t1+(-1)^j*gamma(2*j+1)/x^(2*j);
  t2=t2+(-1)^j*gamma(2*j+2)/x^(2*j);
 end;
 si(mm)=pi/2-(cos(x)/x*t1+sin(x)/x^2*t2);
else ;  %  x between 3, 10
  %si(3)=1.848652528...
  temp=1.848652528 + quad8(inline('sin(t)./t'),3,x,1e-6);
  si(mm)=temp;
end;

end;



