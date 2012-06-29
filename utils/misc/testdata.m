function A=testdata(r,c)
% TESTDATA - provide randomly generated test data
%
% SYNTAX
% A=testdata - set A to a randomly generated 4320x2160 array
%
% A=testdata(r,c) - set A to a randomly generated r x c array
%
% EXAMPLE
% A=testdata

if nargin==0
    r=4320;
    c=2160;
end
A=EasyInterp2(rand(5),r,c,'linear');