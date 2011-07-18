function val=percentile(A,p)
% percentile - return the value of the p percentile of A or the p*100
% percentile of A if p is < 1
if p>1
    p=p/100;
end
L=sort(A(:));
val=L(round(length(L)*p));