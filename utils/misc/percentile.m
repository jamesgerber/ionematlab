function val=percentile(A,p)
if p>1
    p=p/100;
end
L=sort(nonzeros(A));
val=L(round(length(L)*p));