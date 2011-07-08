function [a,i]=nearestelement(A,x)
[~,i]=min(abs(A-x));
a=A(i);