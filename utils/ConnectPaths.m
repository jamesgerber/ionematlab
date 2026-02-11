function ConnectPaths(RecursionFlag)
% Connectpaths - recursively add paths
%
%  Syntax
%  Connectpaths;  adds all subdirectories to path
%  Connectpaths(1) acts recursively

if nargin==0
    RecursionFlag=0;
end

[pathstr,name]=fileparts(pwd);
base=[fullfile(pathstr,name) filesep];


a=dir(base);

ii=find([a.isdir]);  
%notes on this line of code:  [a.isdir] is matlab structure handling stuff.
% ii will now contain indices into structure a corresponding to
% directories.  if it's not a direcotry, we don't care about it ... not
% goint to add it to the path.  if it is a directory, we need to make sure
% that it isn't "." or ".." 


for j=ii  %j taking on the indices of a where a(j) corresponds to a directory.
    if ~strcmp(a(j).name(1),'.')  %check to see if first character is "."
        addpath([base a(j).name],'-end');  %add path

        if RecursionFlag==1
            cd([base a(j).name])
            ConnectPaths(1)
            cd ../
        end
    
    end
end


if ~(isequal(getenv('USER'),'jsgerber') | isequal(getenv('USER'),'emilycassidy'))
    error(' I have surely broken this for other users as I transition my utils directory from ionematlab/ to jgutils/')
end

rmpath([pwd '/ionedata'])
rmpath([pwd '/ionefile'])
rmpath([pwd '/ionesurf'])
rmpath([pwd '/ionealphachannel'])
rmpath([pwd '/misc'])
rmpath([pwd '/ionegeo'])
rmpath([pwd '/ionegraphics'])
rmpath([pwd '/ionematrix'])
rmpath([pwd '/structureutils'])
rmpath([pwd '/zcapnames'])
rmpath([pwd '/znocapnames'])

wd=pwd;
cd ../../jamesutils/
ConnectPaths
cd(wd)
