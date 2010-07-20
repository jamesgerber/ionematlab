function B=EasyInterp2(A,rows,cols)
if nargin==2
    cols=round(size(A,2)*rows);
    rows=round(size(A,1)*rows);
end
R=(1:(size(A,2)-1)/(cols-1):size(A,2));
C=(1:(size(A,1)-1)/(rows-1):size(A,1));
B=interp2(A,R,rot90(C,3));