function [maxval,RowIndex,ColumnIndex]=max2d(z)
% Max2d - returns max value, row index, and column index
%
%  SYNTAX
%         [MaxVal,RowIndex,ColumnIndex]=max2d(z);
%
%
%  example
%
%          z=rand(5,12);
%          z(3,1)=2.7;
%          [MaxVal,RowIndex,ColumnIndex]=max2d(z)
%          z(RowIndex,ColumnIndex)
%           
% location of maximum value:
    [maxcolval,colindex]=max(z);
    [maxval,rowindex]=max(maxcolval);
  
    RowIndex=colindex(rowindex);
    ColumnIndex=rowindex;
    