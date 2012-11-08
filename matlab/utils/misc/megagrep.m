function MegaGrep(varargin) 
%MEGAGREP - execute a shell command in every directory on path
%
% Execute a dos command in every directory on the path which
% doesn't contain the string 'toolbox'.  If a single argument is passed in, then
% that argument is assumed to be a valid dos command.  If multiple arguments
% are passed in, they are used as arguments to a grep command.
%
%  SYNTAX
%          (Single Argument)
%          MegaGrep('ls | grep -i certainfile ')  Goes to every directory 
%          on the path (whose name doesn't contain "toolbox") and executes
%          'ls | grep -i certainfile' in a dos shell.  results will 
%          be printed to the screen.
%
%          (multiple Arguments)
%          Megagrep -i CertainVariable *.m    executes "grep -i CertainVariable *.m" 
% 
%  EXAMPLE        
%          megagrep(' ''Maximum Generator Force'' ','*.m')
%
%
% REMARKS
% Megagrep also looks in private directories.
%
% See Also: MegaEdit, ChebWin, UIPutFile
%
% AUTHOR:  James Gerber, with the spiritual guidance of Chris Griffin.

if nargin==0
   help megagrep
   return
end
if nargin==1
   dosargs=varargin{1};
else
   str=[];for j=1:length(varargin);str=[str varargin{j} ' '];end
   dosargs=['grep ' str];
end

wd=pwd;
ListOfDirsToSearch={};   

PathList=path;



PathList=[pathsep PathList pathsep pwd pathsep];
ii=find(PathList==pathsep);

for j=1:length(ii)-1;
   ThisPath=PathList(  (ii(j)+1) : (ii(j+1))-1 );
   if isempty(findstr('toolbox',ThisPath))
      ListOfDirsToSearch{end+1}=ThisPath;   
   %look to see if there is a private directory
      if exist(fullfile(ThisPath,'private',''),'dir')
          ListOfDirsToSearch{end+1}=fullfile(ThisPath,'private','');
      end
   end
end

disp(['Searching in ...']);
char(ListOfDirsToSearch)


for j=1:length(ListOfDirsToSearch);
   cd(ListOfDirsToSearch{j});
   disp('');
   disp(pwd);
   disp(['! ' dosargs  ]);
   eval(['! ' dosargs  ]);
end

cd(wd);




