function H=cfig(H);
% CFIG  -   Open a figure widnow in the corner of the screen
pos=get(0,'ScreenSize');

X=pos(3);
Y=pos(4);

newpos=[X*.75 Y*.73 X*.24 Y*.2];


if ~exist('H')
   H=figure('position',newpos);
else
   set(H,'position',newpos);
end

