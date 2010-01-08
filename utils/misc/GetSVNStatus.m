function SVNStatus=GetSVNStatus;
% GetSVNStatus - get SVN status from the subversion repository
%
%       Syntax
%          SVNStatus=GetSVNStatus
%
%          GetSVNStatus with no output arguments will force the user to
%          acknowledge that there is some code that isn't checked in.
%
%
%   Example:
%


%

fullpath=which(mfilename);
[s,w]=unix(['svn status ' fullpath(1:end-25)]);

if s==1
    error(['problem with subversion command.  '])
end

if strmatch(w,'working copy') | s==1
    error(['problem with subversion'])
end

SVNStatus=w;

if nargout==0 &~isempty(w)
    w
    % break out w
    ii=find(w==w(end));  %take advantage of fact that w ends with return
    if isempty(ii)
        error   
    end
    
    iiStart=ones(size(ii));
    iiStart(2:end)=ii(1:end-1)+1;
    iiEnd=ii-1;
    
     end
    
    
    ButtonName = questdlg('Matlab code not checked in.  Proceed?', ...
        'Some Matlab code not checked in', ...
        'Yes', 'Help','Help');
    switch ButtonName,
        case 'Yes',
            disp('OK');
        case 'Help',
            
            if length(findstr(w,'?')>0)
                disp(['you may need to execute these lines from terminal:'])
                
                for j=1:length(ii)
                
                    ThisLine=w(iiStart(j):iiEnd(j));
                    if ThisLine(1)=='?'
                        disp(['svn add ' ThisLine(2:end)])
                    end
                end
            disp([' '])    
            end
            

            disp('You may need to run this from a terminal window: ');
            disp(['svn commit ' fullpath(1:end-25) ' -m "message here"']);
            disp(['svn update ' fullpath(1:end-25)]);
            error('crashing ...')
    end % switch
end
