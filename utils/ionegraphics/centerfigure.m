function O=centerfigure(I)
saveto=[];
if (isstr(I))
    saveto=I;
    I=imread(I);
end
tol=max(max(max(I)))/32;
c1=I(1,1,1);
c2=I(1,1,2);
c3=I(1,1,3);
centerrow=I(round(size(I,1)/2),:,:);
tmp=1:length(centerrow);
find(closeto(centerrow(:,:,1),c1,tol)&...
    closeto(centerrow(:,:,2),c2,tol)&...
    closeto(centerrow(:,:,3),c3,tol))
tmp(find(closeto(centerrow(:,:,1),c1,tol)&...
    closeto(centerrow(:,:,2),c2,tol)&...
    closeto(centerrow(:,:,3),c3,tol)))=0;
left=nearestNonZero(1,1,tmp);
right=nearestNonZero(1,length(tmp),tmp);
offset=round((left+right-length(tmp))/2);
tmp1=1:size(I,1);
means=zeros(size(I,1),3);
for i=1:length(means)
    means(i,1)=mean(I(i,:,1));
    means(i,2)=mean(I(i,:,2));
    means(i,3)=mean(I(i,:,3));
end
tmp1(find(~closeto(means(:,1),c1,tol/100)|...
    ~closeto(means(:,2),c2,tol/100)|...
    ~closeto(means(:,3),c3,tol/100)))=0;
top=nearestNonZero(1,round(length(tmp1)/2),tmp1(1:round(length(tmp1)/2)));
bottom=nearestNonZero(1,1,tmp1(round(length(tmp1)/2):length(tmp1)));
save imsavedata
O=I;
O(top:bottom,:,1)=c1;
O(top:bottom,:,2)=c2;
O(top:bottom,:,3)=c3;
O(top:bottom,(left-offset):(right-offset),:)=I(top:bottom,left:right,:);
if ~isempty(saveto)
    imwrite(O,saveto);
end