function highresdata=disaggregate_rate(loresdata,N);
% disaggregate - spread data/ha out to a smaller resolution
%
%  Syntax
%     highresdata=disaggregate_rate(loresdata,N);
%
%  Example
%     hda=GetHalfDegreeGridCellAreas;
%     halfdegreearea=disaggregate_rate(hda,6);
%
%     See also:  disaggregate_quantity

[r,c]=size(loresdata);
highresdata(r*N,c*N)=0;
for j=1:N
    for m=1:N
        highresdata(j:N:(N*r),m:N:(N*c))=loresdata;
    end
end
