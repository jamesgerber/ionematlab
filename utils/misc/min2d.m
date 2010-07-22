function [minval,RowIndex,ColumnIndex]=min2d(z)
% Max2d - returns min value, row index, and column index
%
%  SYNTAX
%         [MinVal,RowIndex,ColumnIndex]=min2d(z);
%
%
%  example
%
%          z=rand(5,12);
%          z(3,1)=2.7;
%          [MinVal,RowIndex,ColumnIndex]=min2d(z)
%          z(RowIndex,ColumnIndex)
%           
% location of minimum value:
    [mincolval,colindex]=min(z);
    [minval,rowindex]=min(mincolval);
  
    RowIndex=colindex(rowindex);
    ColumnIndex=rowindex;
    