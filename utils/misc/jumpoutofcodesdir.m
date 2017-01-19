function jumpoutofcodesdir
% cheesy function to jump out of a 'codes/' directory

% this allows me to let matlab change the current directory.  although just
% writing this comment here has wasted all the time this function will ever
% save me. 
a=pwd;

if strmatch(a(end-4:end),'codes')==1
    % we are in codes directory
    evalin('caller','cd ..');
end