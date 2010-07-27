function [IM CMAP]=MakeIndexed(Image)
%Image is a normal rgb image, outputs an indexed image and its associated
%colormap. Inefficient, but some functions can only use indexed images.
CMAP=zeros(size(Image,1)*size(Image,2),3);
IM=zeros(size(Image,1),size(Image,2));
CNext=1;
for i=1:size(Image,1)
    for j=1:size(Image,2)
        CMAP(CNext,:)=[Image(i,j,1) Image(i,j,2) Image(i,j,3)];
        IM(i,j)=CNext;
        CNext=CNext+1;
    end
end
CMAP=scaletodouble(CMAP);