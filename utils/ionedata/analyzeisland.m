function [rv,cv,area,edge]=analyzeisland(r,c,A)
% recursion is technically avoided thanks to use of actual strings to store
% a list of what would otherwise be recursive commands

core=A(r,c);
check=zeros(size(A));
edge=0;
commandr=r;
commandc=c;
rv=[];
cv=[];
while ~isempty(commandr)
    r2=commandr(1);
    c2=commandc(1);
    if (~(r2<1||c2<1||r2>size(A,1)||c2>size(A,2))&&A(r2,c2)==core)
        if (check(r2,c2)==0)
            check(r2,c2)=1;
            rv(length(rv)+1)=r2;
            cv(length(cv)+1)=c2;
            commandr((length(commandr)+1):(length(commandr)+4))=[r2-1,r2,r2+1,r2];
            commandc((length(commandc)+1):(length(commandc)+4))=[c2,c2-1,c2,c2+1];
        end
    else edge=edge+1;
    end
    commandr=commandr(2:length(commandr));
    commandc=commandc(2:length(commandc));
end
area=length(rv);