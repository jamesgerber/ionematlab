function [r,c]=center(A,val,squeeze,ri,ci,breadth,depth)
if nargin<7
    depth=1;
end
if nargin<3
    squeeze=0;
end
for i=1:depth
    sqerror=((A-val).^2+squeeze).^-1;
    
    rweights=zeros(size(A));
    for c=1:size(A,2)
        rweights(:,c)=1:size(A,1);
    end
    
    cweights=zeros(size(A));
    for r=1:size(A,1)
        cweights(r,:)=1:size(A,2);
    end
    
    if (nargin>=6)
        sqerror=sqerror.*(abs(ri-rweights)<breadth);
        sqerror=sqerror.*(abs(ci-cweights)<breadth);
    end
    
    rweights=rweights.*sqerror;
    cweights=cweights.*sqerror;
    ri=sum(sum(rweights))./sum(sum(sqerror));
    ci=sum(sum(cweights))./sum(sum(sqerror));
end
r=ri;
c=ci;