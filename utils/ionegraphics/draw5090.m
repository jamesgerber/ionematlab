function draw5090(Data)
%INTERP2 draw a figure highlighting data at the 50th and 90th percentiles
%
%   fill5090(Data) plots Data on a Robinson projection and fills in all
%   cells at the 50th and 90th percentiles of the nonzero points with
%   solid color.
%
%   Example:
%
%   S=OpenNetCDF([iddstring 'Crops2000/crops/maize_5min.nc'])
%   tmp=S.Data(:,:,2);  %yield ... not area
%   draw5090(tmp);
%
%   See also fill5090
    load worldindexed;
    Data=fliplr(EasyInterp2(double(Data),4320,2160));
    bmap=immap;
    backdata=rot90(im,3)+1;
    tmp=sort(nonzeros(Data));
    newmap=zeros(length(bmap)+1,3);
    newmap(1,:)=[0.7,0.0,0.7];
    newmap(length(newmap)+1,:)=[0.9,0.9,0.0];
    for i=1:length(bmap)
        newmap(i+1,:)=bmap(i,:);
    end
    backdata(Data>tmp(round(length(tmp)*.495))&Data<tmp(round(length(tmp)*.505)))=1;
    backdata(Data>tmp(round(length(tmp)*.895))&Data<tmp(round(length(tmp)*.905)))=length(newmap);
    hm=axesm('robinson');
    NumPointsPerDegree=12;
    R= [NumPointsPerDegree,90,-180];
    h=meshm(double(backdata.'),R,[50 100],-1);
    colormap(newmap);