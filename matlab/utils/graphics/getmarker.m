function linetype=getmarker(j);
% GETMARKER returns a string which can be a style, marker then color
%
%  SYNTAX  getmarker(3) 
%
%  EXAMPLE
%
%   figure
%   t=0:.05:1;
%   for j=1:20
%      plot(t,sin( t*j),getmarker(j));
%      hold on
%   end
%   figure
%   t=0:.05:1;
%   for j=1:20
%      mc=getmarker(j);
%      plot(t,sin( t*j),mc(1));
%      hold on
%   end



types={'b','g','r','m','c','y','k'};

colortype=types{rem(j-1,length(types))+1};
    
types={'x','o','+','*','p','^','s','d','v','h','>','<'};

markertype=types{rem(j-1,length(types))+1};

linetype=[markertype colortype];
