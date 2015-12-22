function [GitHash,Date,Editor]=getgitinfo(varargin);
% GetSVNInfo - get revision info from the subversion repository
%
%       Syntax
%          [GitHash,Date,Editor]=getgitinfo;
%This code allows you to pull in the most recent commit info for the given
%code you are working with. It will pull out the Git Hash, Last Commit Date
%and the Author of the last commit date.
%   Example:
%
%   This would go inside a processing code ...
%
%    DataToSave=ProcessedData;
%    [GitHash,Date,Editor]=getgitinfo;
%    DAS.GitRevisionHash=GitHash;
%    DAS.LastChangeDate=Date;
%    DAS.LastEditor=Editor;
%    DAS.ProcessingDate=datestr(now);
%    save SavedDataFile DataToSave DAS
%
%       See Also: getgitstatus
%
% MO 12/2015, Global Landscapes Initiative @ Institute on the Environment

fullpath=which(mfilename);
disp(fullpath)
disp([fullpath(1:end-24)]);

if nargin==0
    [ST,I]=dbstack('-completenames');
    S=ST(max(1,end-1)).file;
else
    S=which(varargin{1})
end



try


    [s,d]=unix(['export TERM=ansi; /usr/local/bin/git -C ' fullpath(1:end-24) ' log -n 1 --pretty=format:"%h-%cn-%cd" -- ' fullpath]);
    
    AllInfo=d;
    
    
    %ii= find(d==sprintf('\n'))
   
    
end

%get commit date
splt_by_hash=strsplit(AllInfo,'-');
GitHash=splt_by_hash(1);
Date=splt_by_hash(3);
Editor=splt_by_hash(2);

    