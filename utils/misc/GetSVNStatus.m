function varargout=GetSVNStatus(varargin);
% GetSVNStatus - get SVN status from the subversion repository
%
%       Syntax
%          GETSVNSTATUS - will tell user the results of SVN status command
%          and also print out a help message with syntax of commands to
%          bring repository up to date
%
%          SVNStatus=GetSVNStatus('confirm') will force user to choose to
%          proceed if repository is not up to date.
%
%
%       See Also: GetSVNInfo


%  jsg
%  IonE - Jan 2010

fullpath=which(mfilename);
[s,w]=unix(['svn status ' fullpath(1:end-25)]);

if s==1
    error(['problem with subversion command.  '])
end

if isempty(w)
    disp('');
    disp(['Local changes are checked into subversion repository'])
    disp(['WARNING!  SERVER MAY HAVE NEWER FILES AND YOU NEED TO UPDATE!'])
    SVNStatus='';
    return
end

if strmatch(w,'working copy') | s==1
    error(['problem with subversion'])
end

if nargout==1
varargout{1}=w;
end

disp(['output from SVN command']);
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

disp('You may need to run this from a terminal window: ');
disp(['svn commit ' fullpath(1:end-25) ' -m "message here"']);
disp(['svn update ' fullpath(1:end-25)]);
disp([' '])


if ~isempty(w) & nargin>0 & isequal(lower(varargin{1}),'confirm')
    
    ButtonName = questdlg('Matlab code not checked in.  Proceed?', ...
        'Some Matlab code not checked in', ...
        'Yes', 'No','Yes');
    switch ButtonName,
        case 'Yes',
            disp('OK');
        case 'No',
            
            error('crashing ...')
    end % switch
end




