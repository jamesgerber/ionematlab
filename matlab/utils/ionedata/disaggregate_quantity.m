function highresdata=disaggregate_quantity(loresdata,N);
% disaggregate_quantity - spread data out to a smaller resolution
%
%  Syntax
%     highresdata=disaggregate_quantity(loresdata,N);
%
%  Example
%     loresdata=testdata(100,50);
%     highresdata=disaggregate_quantity(testdata,.1);
%
%    See also: disaggregate_rate

[r,c]=size(loresdata);
highresdata(r*N,c*N)=0;
for j=1:N
    for m=1:N
        highresdata(j:N:(6*r),m:N:(6*c))=loresdata/(N^2);
    end
end
