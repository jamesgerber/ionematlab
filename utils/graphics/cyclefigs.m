function cyclefigs
%CYCLEFIGS - cycle through all figures, hit any key to proceed.

% JSG Jan 2009
h=allchild(0);

disp([' Hit any Key ...'])

for j=1:length(h)
   if isequal(get(h(j),'type'),'figure');
      figure(h(j));
      pause
   end
end
