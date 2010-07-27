function B=EasyInterp2(A,rows,cols,method)
if nargin<4
    method='linear';
end
if nargin==2
    cols=round(size(A,2)*rows);
    rows=round(size(A,1)*rows);
else
    if ischar(cols)
        method=cols;
        cols=round(size(A,2)*rows);
        rows=round(size(A,1)*rows);
    end
end
R=(1:(size(A,2)-1)/(cols-1):size(A,2));
C=(1:(size(A,1)-1)/(rows-1):size(A,1));
B=interp2(A,R,rot90(C,3),method);