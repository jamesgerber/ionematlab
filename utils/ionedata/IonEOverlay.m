function O=IonEOverlay(newdata,where,recipient)
%Put newdata onto recipient as directed by where, a logical matrix or
%linear indices.
%For example, IonEOverlay(A,A>10,B) puts A onto B where A>10, and
%IonEOverlay(A,find(A>10),B) does the same thing.
if ~isempty(find(where~=1&where~=0))
    %Linear indices. We don't need to do anything.
else
    %Logical array or matrix. Find linear indices.
    where=find(where);
end
for i=1:size(where)
    recipient(where(i))=newdata(where(i));
end
O=recipient;