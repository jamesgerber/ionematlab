function [ii,value]=closest(vec,val);
% closest - return closest index
%
%  Syntax
%       ii=closest(vector,value)
%       [ii,closevalue]=closest(vector,value)
%
%  See also  closestvalue

if length(val)==1
    [value,ii]=closestvalue(vec,val);
else
    [value,ii]=closestvalue(val,vec);
end