function output=Amazonia;
% AMAZONIA -  logical array of amazonia
%
%  Syntax
%
%      LogicalMatrix=Amazonia - returns
%

persistent LogicalMatrix

load([iddstring '/misc/watersheds/globe1.mat'])

LogicalMatrix = zeros(4320,2160);

LogicalMatrix(Q == 2160) = 1;

LogicalMatrix(Q == 2320) = 1;


output = LogicalMatrix;

end
