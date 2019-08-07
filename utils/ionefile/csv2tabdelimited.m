function csv2tabdelimited(inputfilename,outputfilename)
% csv2tabdelimited - prepare a .csv file for reading in with tabs
%
%
%   syntax 
%           csv2tabdelimited(inputfilename,outputfilename)
%           csv2tabdelimited(inputfilename)
%     
%   if a .csv file has lines like this:  ReadGenericCSV gets confused.
%   0577400,"Almonds, Shelled Basis",AG,"Algeria",2001,2010,10,176,"Ending Stocks",21,"(MT)",0
%
%   this function turns those lines into something like this:
%   0577400	"Almonds, Shelled Basis"	AG	"Algeria"	2001	2010	10	176	"Ending Stocks"	21	"(MT)"	0
%   where those are tabs.
%
%   Note that readgenericcsv has an option to read in a tab-delimited file.
%
%   Note also the following unix command, which will remove all instances
%   of double quotes '"'
%
%     sed  's/"//g' World2000.txt > World2000nq.txt
%
%     if the .txt file contains strange characters, then try this:
%     LC_CTYPE=C sed  's/"//g' World2000.txt > World2000nq.txt
%
%
%  See Also:  readgenericcsv

inputfilename=fixextension(inputfilename,'.csv');

if nargin==1
    outputfilename=strrep(inputfilename,'.csv','.txt');
end


fid=fopen(inputfilename,'r');
fidout=fopen(outputfilename,'w');
x=fgetl(fid)

while x~=-1
ii=find(x==',');
jj=find(x=='"');

putbacktocommas=zeros(size(x));
for m=1:2:length(jj);
    indices=(jj(m)+1:jj(m+1)-1);
    
    tmp=x(indices);

    kk=(tmp==',');
    putbacktocommas(indices)=kk;
end
    
xtmp=strrep(x,',',tab);
xtmp(find(putbacktocommas))=',';

fprintf(fidout,'%s\n',xtmp);
x=fgetl(fid);

end
fclose(fid)
fclose(fidout)
    