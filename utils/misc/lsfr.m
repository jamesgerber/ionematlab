function lsft
% lsf list only directories
if isunix
unix(['ls -Ftr | grep /']);
%unix(['ls -lF | grep /']);
end