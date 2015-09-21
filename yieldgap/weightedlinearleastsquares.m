function [a,b,c,Rsq]=WeightedLinearLeastSquares(y,G,M,W)
% WeightedLinearLeastSquares - Weighted Linear Least Squares
%
%
%   Syntax
%       [a,b,c,Rsq]=WeightedLinearLeastSquares(y,X1,X2,W);
%
%       

y=y(:);
G=G(:);
M=M(:);
W=W(:);
if length(W)==1;
    W=W*ones(size(y));
end

gy=sum(y.*G.*W);
gg=sum(G.*G.*W);
gm=sum(M.*G.*W);
my=sum(M.*y.*W);
mm=sum(M.*M.*W);
g=sum(G.*W);
m=sum(M.*W);
ybar=sum(y.*W);
w=sum(W);


T=[gg gm g ; gm mm m ; g m w];

vector=[gy my ybar];
abc=vector*inv(T);
%abc=inv(T)*vector';
a=abc(1);
b=abc(2);
c=abc(3);

E=sum( (y-(a*G+b*M+c)).^2);


%%% try to figure out Rsq
f=(a*G+b*M+c);  %this is the model


SSerr=sum( (y-f).^2.*W.^2);
SStot=sum( (y-mean(y)).^2.*W.^2);
SSreg=sum( (f-mean(f)).^2.*W.^2);

Rsq=1-SSerr/SStot;

