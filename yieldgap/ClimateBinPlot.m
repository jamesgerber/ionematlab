load ClimateMask_Maize_GDD8_prec_5x5_RevH


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
for j=1:5
  cv=vect{j};

  NewBlock=[cv(1)*bc cv(2)*bc cv(3)*bc];
  for k=1:5
  cmap=[cmap ; NewBlock*s(k)];
  end
end

newmap=finemap(cmap);%,'emblue','white');

NSS.coloraxis=[1 25];
NSS.cmap=newmap;
NSS.TitleString='Climate Zones. Maize.';
%NSS.units='dry/cold to warm/wet';
a=BinMatrix;
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




figure

x=1:5;
y=1:5;
for j=1:5
  for k=1:5
    cv=vect{j};
    color=cv*s(k);
    xvect=[x(j)-.5 ,x(j)+.5, x(j)+.5, x(j)-.5, x(j)-.5];
    yvect=[y(k)-.5 ,y(k)-.5, y(k)+.5, y(k)+.5, y(k)-.5];    

    patch(xvect,yvect,color)
  end
end

set(gca,'visib','off')
hx=text(3,0.125,'GDD');
set(hx,'FontSize',30,'HorizontalAlignment','Center');
hy=text(0.125,3,'precipitation');
set(hy,'FontSize',30,'HorizontalAlignment','Center','Rotation',90);


OutputFig('Force','ClimateBinLegend_5x5','-r75')