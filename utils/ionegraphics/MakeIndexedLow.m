function [IM CMAP]=MakeIndexedLow(Image,q)
%Image is a normal double rgb image, outputs an indexed image and its
%associated colormap. Slow, but can produce nicely-compressed results.
Image=ScaleToDouble(Image);
IM=zeros(size(Image,1),size(Image,2),'double');
CNext=1;
CMAP=zeros(0,3,'double');
for i=1:size(Image,1)
    for j=1:size(Image,2)
        tmp=q*.5;
        pos=0;
        for k=1:size(CMAP,1)
            if (abs(Image(i,j,1)-CMAP(k,1))<tmp&&abs(Image(i,j,2)-CMAP(k,2))<tmp&&abs(Image(i,j,3)-CMAP(k,3))<tmp)
                tmp=max([abs(Image(i,j,1)-CMAP(k,1)) abs(Image(i,j,2)-CMAP(k,2)) abs(Image(i,j,3)-CMAP(k,3))]);
                pos=k;
            end
        end
        if (pos==0)
            CNext=CNext+1;
            CMAP(CNext,:)=[min([Image(i,j,1)+q*.5-mod(Image(i,j,1)+q*.5,q),1.0]) min([Image(i,j,2)+q*.5-mod(Image(i,j,2)+q*.5,q),1.0])...
                min([Image(i,j,3)+q*.5-mod(Image(i,j,3)+q*.5,q),1.0])];
            IM(i,j)=CNext;
        else
            IM(i,j)=pos;
        end
    end
end