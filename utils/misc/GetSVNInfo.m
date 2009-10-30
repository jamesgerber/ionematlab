function [AllInfo,Revision]=GetSVNInfo;

[ST,I]=dbstack('-completenames')


[s,d]=unix(['svn info ' ST(2).file]);
AllInfo=d


ii= find(d==sprintf('\n'))
RevLine=d(ii(5):ii(6));

Revision=str2num(RevLine(11:end))
