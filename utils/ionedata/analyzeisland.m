function [ro,co,area,perim]=analyzeisland(r,c,N)
global core;
core=N(r,c);
global A;
A=N;
global check;
check=zeros(size(A));
global rv;
global cv;
global edge;
edge=0;
examine(r,c);
ro=rv;
co=cv;
perim=edge;
area=length(rv);
clear global core A check rv cv edge;

function examine(r2,c2)
global core;
global A;
global check;
global rv;
global cv;
global edge;
if (~(r2<1||c2<1||r2>size(A,1)||c2>size(A,2))&&A(r2,c2)==core)
    if (check(r2,c2)==0)
     check(r2,c2)=1;
     rv(length(rv)+1)=r2;
     cv(length(cv)+1)=c2;
     examine(r2-1,c2);
     examine(r2,c2-1);
     examine(r2+1,c2);
     examine(r2,c2+1);
    end
else edge=edge+1;
end