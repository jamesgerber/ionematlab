function m=maxval(A)
% MAXVAL - return maximum element of A of any dimension
m=A;
for i=1:length(size(A))
    m=max(m);
end