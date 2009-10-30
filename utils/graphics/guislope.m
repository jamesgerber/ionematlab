function [slope,x1,y1,x2,y2]=guislope;
% GUISLOPE - graphical slope checker
%
%  Syntax
%          [slope,x1,y1,x2,y2]=guislope;
%
%

[run,rise]=ginput(2);
slope=(rise(2)-rise(1))/(run(2)-run(1));
x1=run(1);
x2=run(2);
y1=rise(1);
y2=rise(2);
