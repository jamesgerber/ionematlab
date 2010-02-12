function finemap;
% FINEMAP - interpolate the colormap finely and put blue on the bottom
map=colormap('summer');

x=1:length(map);
xx=1:.1:x(end);

for j=1:3;
  mapp(:,j)=interp1(x,map(:,j),xx);
end

mapp(2:end+1,:)=mapp;
mapp(1,:)=[0 0 0];

mapp(2:end+1,:)=mapp;
mapp(1,:)=[0.2 0.2 .3];
mapp(1,:)=[127/255 1 212/255]
colormap(mapp)