function fill5090(Data)
% FILL5090 draw a figure highlighting data above the 50th and 90th percentiles
%
%   fill5090(Data) plots Data on a Robinson projection and fills in all
%   cells above the 50th and 90th percentiles of the nonzero points with
%   solid color.
%
%   Example:
%
%   S=opennetcdf([iddstring 'Crops2000/crops/maize_5min.nc'])
%   tmp=S.Data(:,:,2);  %yield ... not area
%   fill5090(tmp);
%
%   See also draw5090
    load worldindexed;
    Data=fliplr(easyinterp2(double(Data),4320,2160));
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
    Data=0;
    bmap=0;
    immap=0;
    backdata=0;
    im=0;
    tmp=0;
    newmap=0;
    bmap=0;
    hm=0;
    h=0;
    R=0;
    NumPointsPerDegree=0;