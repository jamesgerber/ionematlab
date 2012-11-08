function showfigs
%SHOWFIGS - bring figs to top of screen
%
% see also cyclefigs

% JSG May 2010
h=allchild(0);

for j=1:length(h)
   if isequal(get(h(j),'type'),'figure');
      figure(h(j));
   end
end
