function highresdata=disaggregate_rate(loresdata,N);
% disaggregate - spread data/ha out to a smaller resolution
%
%  Syntax
%     highresdata=disaggregate_rate(loresdata,N);
%
%  Example
%     hda=gethalfdegreegridcellareas;
%     halfdegreearea=disaggregate_rate(hda,6);
%
%     See also:  disaggregate_quantity

[r,c]=size(loresdata);
highresdata(r*N,c*N)=0;
for j=1:N
    for m=1:N
        highresdata(j:N:(6*r),m:N:(6*c))=loresdata;
    end
end
