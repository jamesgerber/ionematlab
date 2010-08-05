function fill5090(Data)
    load worldindexed;
    Data=fliplr(EasyInterp2(Data,4320,2160));
    bmap=immap;
    backdata=rot90(im,3)+1;
    tmp=sort(nonzeros(Data));
    newmap=zeros(length(bmap)+1,3);
    newmap(1,:)=[0.7,0.0,0.7];
    newmap(length(newmap)+1,:)=[0.9,0.9,0.0];
    for i=1:length(bmap)
        newmap(i+1,:)=bmap(i,:);
    end
    backdata(Data>tmp(round(length(tmp)*.5)))=1;
    backdata(Data>tmp(round(length(tmp)*.9)))=length(newmap);
    hm=axesm('robinson');
    NumPointsPerDegree=12;
    R= [NumPointsPerDegree,90,-180];
    h=meshm(double(backdata.'),R,[50 100],-1);
    colormap(newmap);