function [RevNo,RevString,LCRevNo,LCRevString,AllInfo]=GetSVNInfo(varargin);
% GetSVNInfo - get revision info from the subversion repository
%
%       Syntax
%          [RevNo,RevString,LCRevNo,LCRevString,AllInfo]=GetSVNInfo;
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


if nargin==0
    [ST,I]=dbstack('-completenames');
    S=ST(end).file;
else
    S=which(varargin{1})
end


[s,d]=unix(['/usr/bin/svn info ' S]);

AllInfo=d;

ii= find(d==sprintf('\n'));
RevLine=d(ii(5):ii(6)-1);

RevNo=str2num(RevLine(11:end));
RevString=['Revision ' RevLine(11:end) ' of ' ...
    S];

LastChangedLine=d(ii(9):ii(10)-1);
LCRevNo=str2num(LastChangedLine(19:end));
LCRevString=[LastChangedLine ' ' S];



if nargout==0
    disp(['Revision of ' mfilename ' is ' num2str(RevNo) ]);
end

