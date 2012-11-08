function linetype=getlinestyle(j);
% GETLINESTYLE - return a unique line style and color and marker
%
%  SYNTAX  
%        getlinetype(INDEX) returns a string which can be a style
%        where INDEX is an integer
%
%  EXAMPLE
%
%   figure
%   t=0:.05:1;
%   for j=1:20
%      plot(t,sin( t*j),getlinemarker(j));
%      hold on
%   end

markers={'x','o','+','*','p','d','s'};
colors={'b','g','r','m','c','k'};
linetypes={'-','--','-.',':'};


   linetype=[grab(colors,j) grab(markers,j) grab(linetypes,j)]; 

function str=grab(cellvect,idx);

str=cellvect{rem(idx-1,length(cellvect))+1};
