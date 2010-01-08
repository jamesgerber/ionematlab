function [RevNo,RevString,LCRevNo,LCRevString,AllInfo]=GetSVNInfo;
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
[ST,I]=dbstack('-completenames');
if length(ST)>0

    [s,d]=unix(['/opt/subversion/bin/svn info ' ST(end).file]);
    AllInfo=d;
    
    ii= find(d==sprintf('\n'));
    RevLine=d(ii(5):ii(6)-1);

    RevNo=str2num(RevLine(11:end));
    RevString=['Revision ' RevLine(11:end) ' of ' ...
        ST(end).file];
    
    LastChangedLine=d(ii(9):ii(10)-1);
    LCRevNo=str2num(LastChangedLine(19:end));
    LCRevString=[LastChangedLine ' ' ST(end).file];
    
else
    error(['problem with dbstack...was this called from command line?'])
end
    