function addpanoplytriangle(triangleflagvector, map)
% ADDPANOPLYTRIANGLE - add triangles to either side of the colorbar
% indicating the color representing values above or below the colorbar
% limits.
%
% SYNTAX
% addpanoplytriangle(triangleflagvector) - triangleflagvector is a
% two-element logical vector. The first value represents whether to display
% a left-side triangle, and the second represents whether to display a
% right-side triangle.
% addpanoplytriangle(triangleflagvector,map) - map is the colormap to use
% for drawing the triangles, instead of the current colormap.
if nargin < 2
    map=colormap;
end

if ischar(map)
    map=finemap(map,'','');
end


endcolor=map(end-1,:);

startcolor=map(2,:);

%create a new axis, but make it invisible
haxnew=axes('visible','off','position',[0 0 1 1 ]);

end_x=0.885;
end_y=0.1;

start_x=1-end_x;
start_y=end_y;

tri_x=[0 0 .0175 0]; 
tri_y=[0 .025 .0125 0]; 

if triangleflagvector(2) == 1
patch(end_x+tri_x,end_y+tri_y,endcolor)
end
if triangleflagvector(1) == 1
patch(start_x-tri_x,start_y+tri_y,startcolor)
end

ZeroXlim(0,1)
ZeroYlim(0,1)
