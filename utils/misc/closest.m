function [ii,value]=closest(vec,val);
% closest - return closest index
%
%  Syntax
%       ii=closest(vector,value)
%       [ii,closevalue]=closest(vector,value)
%
%  See also  ClosestValue

if length(val)==1
    [value,ii]=ClosestValue(vec,val);
else
    [value,ii]=ClosestValue(val,vec);
end