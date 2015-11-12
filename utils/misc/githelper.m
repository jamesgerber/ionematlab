function varargout=githelper(varargin);
% githelper - get git status from the subversion repository
%
%       Syntax
%          githelper - will tell user the results of git status command
%          and also print out a help message with syntax of commands to
%          bring repository up to date
%
%
%       See Also:


%  jsg
%  IonE - Jan 2015

wd=pwd;

fullpath=which(mfilename);
disp(['!git status ' fullpath(1:end-23)]);

try
    cd(fullpath(1:end-23))
    [s,w]=unix(['git status --porcelain']);
    
    
    if isempty(w)
        disp('');
        disp(['Local changes are checked into  repository'])
        disp(['WARNING!  SERVER MAY HAVE NEWER FILES AND YOU NEED TO UPDATE!'])
        SVNStatus='';
        
        disp('You can try to paste this into matlab)');
        disp(['!git update ' fullpath(1:end-25)]);
        disp([' '])
        
        disp('Or run this from a terminal window: (no !)');
        disp(['git update ' fullpath(1:end-25)]);
        disp([' '])
        
        return
    end
    
    
    disp(['output from git status command']);
    w
    
    
    
    if length(findstr(w,'?')>0)
        disp(['you may need to execute these lines from terminal (remove the "!"):'])
        
        % break out w
        ii=find(w==w(end));  %take advantage of fact that w ends with return
        if isempty(ii)
            error
        end
        
        iiStart=ones(size(ii));
        iiStart(2:end)=ii(1:end-1)+1;
        iiEnd=ii-1;
        for j=1:length(ii)
            
            ThisLine=w(iiStart(j):iiEnd(j));
            if ThisLine(1)=='?'
                disp(['! svn add ' ThisLine(2:end)])
            end
        end
        disp([' '])
    end
    
    disp('You may need to run this from a terminal window: (or paste into matlab)');
    disp(['!svn commit ' fullpath(1:end-25) ' -m "message here"']);
    disp(['!svn update ' fullpath(1:end-25)]);
    disp([' '])
    
    
    
    
catch
    cd(wd)
end


