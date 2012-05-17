function output=amazonia;
% AMAZONIA -  logical array of amazonia
%
%  Syntax
%
%      LogicalMatrix=amazonia - returns
%  
%  Example
%
%     x=amazonia;
%     whos x
%     fastsurf(x);
%     
%   Example 2 To create logical after ^^
%     
%     y = logical(x);

load([iddstring 'misc/watersheds/globe1.mat'])

LogicalMatrix = zeros(4320,2160);

LogicalMatrix(Q == 2160) = 1;

LogicalMatrix(Q == 2320) = 1;


output = logical(LogicalMatrix);

end
