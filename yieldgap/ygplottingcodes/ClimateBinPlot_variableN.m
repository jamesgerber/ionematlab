function colors=ClimateBinPlot_variableN(BinMatrix,NSS,CBPS)
%ClimateBinPlot_variableN(BinMatrix,NSS)
%
%  colors=ClimateBinPlot_variableN(BinMatrix,NSS,suppressbox)
%
%  if suppressbox=1 then no box gets printed.  useful if planning a
%  transparency.
%
%   colors is a structure with the rgbmaps of the patches
%
%  CBPS has fields:
%             suppressbox (default 0)
%             titlestring  (default 'Climate Zones.')
%             cmapname (default 'jet')
%             xtext    (default ' GDD ')
%             ytext    (default ' prec')



a=BinMatrix;
a(a==0)=NaN;



suppressbox=0;
titlestring='Climate Zones.';
cmapname='jet';
xtext='  GDD  ';
ytext='  precipitation  ';

if nargin >2
    expandstructure(CBPS);
end
   

NSS.TitleString=titlestring;


%NiceSurfGeneral(BinMatrix,NSS)










N=ceil(sqrt(length(unique(BinMatrix))-1))



%% in this section, need to construct a 10x10 set of colors
%% first a linear colormap

newmap=[];
linearcmap=finemap('red_yellow_blue_deep','','');
linearcmap=finemap('revkbbluered','','');
linearcmap=finemap(cmapname,'','');

s=round(linspace(1,length(linearcmap),N))




for j=1:N
    
    for k=1:N
        
        basecolor=linearcmap(s(j),1:3);
        %        modified_color=ColorFadeFunction(basecolor,k,N);
        modified_color=ColorFadeFunction(basecolor,(N+1-k),N);
        shortmap( (j-1)*N+k,1:3) = modified_color;
        for m=1:16
            newmap(end+1,1:3)=modified_color;
        end
    end
end


newmap=finemap(newmap,'','');



NSS.coloraxis=[1 N^2];
NSS.cmap=newmap;
NSS.cbarvisible='off';

%NSS.uppermap='white';
%NSS.units='dry/cold to warm/wet';
a=double(BinMatrix);

a(a==0)=NaN;

NiceSurfGeneral(a,NSS)
Hfig=gcf;
% turn off colorbar
fud=get(Hfig,'userdata');
set(fud.ColorbarHandle,'visible','off')

if suppressbox==0
    
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
            
            patch(xvect,yvect,shortmap(m,1:3));
            
        end
    end
    
    ZeroXlim(0,N+1);
    ZeroYlim(0,N+1);
    
    set(gca,'visib','off')
    hx=text(N/2+1,0.06125,xtext);
    set(hx,'FontSize',12,'HorizontalAlignment','Center');
    hy=text(0.06125,N/2+1,ytext);
    set(hy,'FontSize',12,'HorizontalAlignment','Center','Rotation',90);
    
    if suppressbox==1
        set(gca,'PlotBoxAspectRatioMode','manual')
    end
end

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
        
        patch(xvect,yvect,shortmap(m,1:3));
        colors(j,k).rgb=shortmap(m,1:3);
        
    end
end

ZeroXlim(0,N+1);
ZeroYlim(0,N+1);


set(gca,'visib','off')
if suppressbox==0
    
    hx=text(N/2+1,0.06125,xtext);
    set(hx,'FontSize',30,'HorizontalAlignment','Center');
    hy=text(0.06125,N/2+1,ytext);
    set(hy,'FontSize',30,'HorizontalAlignment','Center','Rotation',90);
else
    disp('not putting x y labels on stand-alone legend because suppressbox=1')
end

function newcolor= ColorFadeFunction(basecolor,k,N);
% have color fade.  when k=1 newcolor=basecolor;
kslide=linspace(1,.75,N);
newcolor=basecolor*kslide(k);

%% fade to white

newcolor=basecolor.^(1/k);

alpha=(N+1-k)/N;  % starts at 1, goes to 1.N

alpha=(alpha);

newcolor=basecolor*(alpha)+ [1 1 1]*(1-alpha);


