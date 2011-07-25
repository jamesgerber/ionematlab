function OS=smartsurf(data,S)
vert=max(data,[],1);
horiz=max(data,[],2);
vert=find(~isnan(vert));
if isempty(vert)
    OS=nsg(zeros(size(data)),S);
    return;
end
top=vert(1);
bottom=vert(length(vert));
horiz=find(~isnan(horiz));
if isempty(horiz)
    OS=nsg(zeros(size(data)),S);
    return;
end
left=horiz(1);
right=horiz(length(horiz));
[top,left]=rowcol2latlong(left,top,data);
[bottom,right]=rowcol2latlong(right,bottom,data);
S.longlatbox(1)=max(-180,left-(right-left)-10);
S.longlatbox(2)=min(180,right+(right-left)+10);
S.longlatbox(3)=max(-90,bottom-(top-bottom)-5);
S.longlatbox(4)=min(90,top+(top-bottom)+5);
OS=nsg(data,S);