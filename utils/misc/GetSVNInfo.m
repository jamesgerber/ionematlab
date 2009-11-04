function [AllInfo,Revision]=GetSVNInfo;

[ST,I]=dbstack('-completenames')
if length(ST)>0

    [s,d]=unix(['/opt/subversion/bin/svn info ' ST(end).file]);
    AllInfo=d;
    
    
    ii= find(d==sprintf('\n'));
    RevLine=d(ii(5):ii(6));

    Revision=str2num(RevLine(11:end));
else
    ThisPath=which(mfilename);
    keyboard
    dos('/Users/jsgerber/source/matlab/utils/misc/GetSVNInfo.m')
end
    