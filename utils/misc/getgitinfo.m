function [GitHash,Date,Editor]=getgitinfo(vargin);
% GetSVNInfo - get revision info from the subversion repository
%
%       Syntax
%          [GitHash,Date,Editor]=getgitinfo;
%
%   Revision is a version number which can be used to find a version of a
%   code.
%
%   Example:
%
%   This would go inside a processing code ...
%
%    DataToSave=ProcessedData;
%    [RevNo,RevString,LastChangeRevNo,LCRString,AI]=GetSVNInfo;
%    DAS.CodeRevisionNo=RevNo;
%    DAS.CodeRevisionString=RevString;
%    DAS.LastChangeRevNo=LastChangeRevNo;
%    DAS.ProcessingDate=datestr(now);
%    save SavedDataFile DataToSave DAS
%
%       See Also: GetSVNStatus
%
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


    [s,d]=unix(['export TERM=ansi; /usr/local/bin/git -C ' fullpath(1:end-24) ' log --pretty=format:"%H - %cn: %cd, %s" -- ' fullpath]);
    
    AllInfo=d;
    display([AllInfo]);
    
    ii= find(d==sprintf('\n'));
    
    RevLine=d(ii(5):ii(6)-1);
    
end

    
Name=d((ii(1)+7):ii(2)-1);

RevNo=str2num(RevLine(11:end));
RevString=['Revision ' RevLine(11:end) ' of ' ...
    S];

LastChangedLine=d(ii(9):ii(10)-1);
LCRevNo=str2num(LastChangedLine(19:end));
LCRevString=[LastChangedLine ' ' S];



if nargout==0
    disp(['Revision of ' Name ' is ' num2str(RevNo) ]);
end