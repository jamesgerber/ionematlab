function du
% execute du command in unix (space in directories)
if isunix
    unix('du -h -d1');
else
    disp(' not unix ')
end