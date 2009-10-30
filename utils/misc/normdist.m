function y=normdist(x,m,sig);

y=1/sqrt(2*pi)/sig*exp(- (x-m).^2/2/sig.^2);

