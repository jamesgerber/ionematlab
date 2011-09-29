function ClimateBinPlot(BinMatrix,NSS)
%load ClimateMask_Maize_GDD8_prec_5x5_RevH


a=BinMatrix;
a(a==0)=NaN;


if nargin==1
    
    NSS.TitleString='Climate Zones.';
end
%NiceSurfGeneral(BinMatrix,NSS)



N=sqrt(length(unique(BinMatrix))-1)



%% in this section, need to construct a 10x10 set of colors
%% first a linear colormap

newmap=[];
linearcmap=finemap('red_yellow_blue_deep','','');
linearcmap=finemap('revkbbluered','','');
linearcmap=finemap('jet','','');

s=round(linspace(1,length(linearcmap),N))




for j=1:N

    for k=1:N

    basecolor=linearcmap(s(j),1:3);
        modified_color=ColorFadeFunction(basecolor,k,N);
        shortmap( (j-1)*N+k,1:3) = modified_color;
        for m=1:16
            newmap(end+1,1:3)=modified_color;
        end       
    end
end


newmap=finemap(newmap,'','');



NSS.coloraxis=[1 N^2];
NSS.cmap=newmap;

%NSS.uppermap='white';
%NSS.units='dry/cold to warm/wet';
a=double(BinMatrix);

a(a==0)=NaN;

NiceSurfGeneral(a,NSS)
Hfig=gcf;
% turn off colorbar
fud=get(Hfig,'userdata');
set(fud.ColorbarHandle,'visible','off')



hax=axes('position',[.025 .2 .3 .3],'tag','tmpaxis');%,

x=1:N;
y=1:N;
for j=1:N
  for k=1:N
      m=(j-1)*N+k;
   % cv=vect{j};
   % color=cv*s(k);
    xvect=[x(j)-.5 ,x(j)+.5, x(j)+.5, x(j)-.5, x(j)-.5];
    yvect=[y(k)-.5 ,y(k)-.5, y(k)+.5, y(k)+.5, y(k)-.5];    

    patch(xvect,yvect,shortmap(m,1:3))
  end
end

zeroxlim(0,N+1);
zeroylim(0,N+1);

set(gca,'visib','off')
hx=text(N/2+1,0.06125,'  GDD  ');
set(hx,'FontSize',12,'HorizontalAlignment','Center');
hy=text(0.06125,N/2+1,'  precipitation  ');
set(hy,'FontSize',12,'HorizontalAlignment','Center','Rotation',90);

set(gca,'PlotBoxAspectRatioMode','manual')



figure

x=1:N;
y=1:N;
for j=1:N
  for k=1:N
      m=(j-1)*N+k;
   % cv=vect{j};
   % color=cv*s(k);
    xvect=[x(j)-.5 ,x(j)+.5, x(j)+.5, x(j)-.5, x(j)-.5];
    yvect=[y(k)-.5 ,y(k)-.5, y(k)+.5, y(k)+.5, y(k)-.5];    

    patch(xvect,yvect,shortmap(m,1:3))
  end
end

zeroxlim(0,N+1);
zeroylim(0,N+1);

set(gca,'visib','off')
hx=text(N/2+1,0.06125,'  GDD  ');
set(hx,'FontSize',30,'HorizontalAlignment','Center');
hy=text(0.06125,N/2+1,'  precipitation  ');
set(hy,'FontSize',30,'HorizontalAlignment','Center','Rotation',90);

function newcolor= ColorFadeFunction(basecolor,k,N); 
% have color fade.  when k=1 newcolor=basecolor;
kslide=linspace(1,.7,N);
newcolor=basecolor*kslide(k);

%% fade to white

newcolor=basecolor.^(1/k);

alpha=(N+1-k)/N;  % starts at 1, goes to 1.N

alpha=(alpha);

newcolor=basecolor*(alpha)+ [1 1 1]*(1-alpha);


