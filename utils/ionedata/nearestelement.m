function [a,i]=nearestelement(A,x)
% NEARESTELEMENT - return the nearest element to x of 1D array A
[~,i]=min(abs(A-x));
a=A(i);