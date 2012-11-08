function ClimateBinPlot(BinMatrix)
%load ClimateMask_Maize_GDD8_prec_5x5_RevH


a=BinMatrix;
a(a==0)=NaN;

NSS.cmap='sixteencolors';
NSS.TitleString='Climate Zones. Maize.';
NSS.units='dry/cold to warm/wet';
%NiceSurfGeneral(BinMatrix,NSS)





r=[1 0 0]
n=[1 .5 0]
p=[1 0 1];
g=[0 1 0];
c=[1 0 1];
b=[0 0 1];

vect{1}=g;
vect{2}=b;
vect{3}=p;
vect{4}=n;
vect{5}=r;

s=linspace(1,.25,5);

bb=ones(20,3);%building block
bc=ones(20,1);%building column

cmap=[];
% % for j=1:5
% %   cv=vect{j};
% % 
% %   NewBlock=[cv(1)*bc cv(2)*bc cv(3)*bc];
% %   for k=1:5
% %   cmap=[cmap ; NewBlock*s(k)];
% %   end
% % end
[cmap,shortmap]=mapbyhand;

newmap=finemap(cmap);%,'emblue','white');

NSS.coloraxis=[1 25];
NSS.cmap=newmap;
NSS.TitleString='Climate Zones. Maize.';
NSS.uppermap='white';
%NSS.units='dry/cold to warm/wet';
a=double(BinMatrix);

a(a==0)=NaN;

NiceSurfGeneral(a,NSS)
Hfig=gcf;
% turn off colorbar
fud=get(Hfig,'userdata');
set(fud.ColorbarHandle,'visible','off')




z=[1:5;6:10;11:15;16:20;21:25];
a=[1 1 1 1 1];
y=[a;2*a;3*a;4*a;5*a;]
x=y'



hax=axes('position',[.025 .2 .3 .3],'tag','tmpaxis');%,

x=1:5;
y=1:5;
for j=1:5
  for k=1:5
      m=(j-1)*5+k;
   % cv=vect{j};
   % color=cv*s(k);
    xvect=[x(j)-.5 ,x(j)+.5, x(j)+.5, x(j)-.5, x(j)-.5];
    yvect=[y(k)-.5 ,y(k)-.5, y(k)+.5, y(k)+.5, y(k)-.5];    

    patch(xvect,yvect,shortmap(m,1:3))
  end
end

zeroxlim(0,6);
zeroylim(0,6);

set(gca,'visib','off')
hx=text(3,0.1,'  GDD  ');
set(hx,'FontSize',12,'HorizontalAlignment','Center','fontweight','bold');
hy=text(0.125,3,'  precipitation  ');
set(hy,'FontSize',12,'HorizontalAlignment','Center','Rotation',90,'fontweight','bold');


set(gca,'PlotBoxAspectRatioMode','manual')



figure

x=1:5;
y=1:5;
for j=1:5
  for k=1:5
      m=(j-1)*5+k;
   % cv=vect{j};
   % color=cv*s(k);
    xvect=[x(j)-.5 ,x(j)+.5, x(j)+.5, x(j)-.5, x(j)-.5];
    yvect=[y(k)-.5 ,y(k)-.5, y(k)+.5, y(k)+.5, y(k)-.5];    

    patch(xvect,yvect,shortmap(m,1:3))
  end
end


set(gca,'visib','off')
hx=text(3,0.125,'  GDD  ');
set(hx,'FontSize',30,'HorizontalAlignment','Center');
hy=text(0.125,3,'  precipitation  ');
set(hy,'FontSize',30,'HorizontalAlignment','Center','Rotation',90);


%OutputFig('Force','ClimateBinLegend_5x5','-r75')

function [cmap,shortmap]=mapbyhand;

% these colors taken from colorbrewer2
% blue
blue=[
    158 202 225
    107 174 214
    66 146 198
    33 113 181
    8 69 148];

green=[
    161 217 155
    116 196 118
    65 171 93
    35 139 69
    0 90 50];

purple=[
    188 189 220
    158 154 200
    128 125 186
    106 81 163
    74 20 134];

orange=[
    253 174 107
    253 141 60
    241 105 19
    217 72 1
    140 45 4];

red=[
    252 146 114
    251 106 74
    239 59 44
    203 24 29
    153 0 13];

map=[purple;blue;green;orange;red]/255;
    


newmap=[];

for j=1:length(map)
    for k=1:16
        newmap(end+1,1:3)=map(j,1:3);
        %   newmap(end+1:end+16,2)=map(j,2);
        %   newmap(end+1:end+16,3)=map(j,3);
    end
end
shortmap=map;
cmap=newmap;


    





