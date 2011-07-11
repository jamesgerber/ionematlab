function m=minval(A)
% MINVAL - return minimum element of A of any dimension
m=A;
for i=1:length(size(A))
    m=min(m);
end