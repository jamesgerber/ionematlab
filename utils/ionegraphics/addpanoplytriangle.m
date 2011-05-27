%ud=get(gcf,'UserData');
% need output structure to get colormap



map=colormap;

endcolor=map(end-1,:);

startcolor=map(2,:);

%create a new axis, but make it invisible
haxnew=axes('visible','off','position',[0 0 1 1 ]);

% need to turn of scaling for this axis
end_x=0.9
end_y=0.1;

start_x=.1;
start_y=end_y;


tri_x=[ -.1 .1 0 -.1];
tri_y=[-.1 -.1 .1 -.1];


patch(end_x+tri_x,end_y+tri_y,endcolor)

patch(start_x+tri_x,start_y+tri_y,startcolor)
zeroxlim(0,1)
zeroylim(0,1)
