function colortrend(t,x,y,N,xunits,yunits)
% Colortrend - produce plot showing correlation changes with time
%
%  Syntax
%
%  colortrend(t,x,y,N)
%
% % Example:
%    t=1:300;
%    beta=[[1:100]*0+10 [1:100]*0+20 [1:100]*0+12];
%    v=sin(t*10);
%    F=v.*beta;
%    colortrend(t,v,F,10,'m/s','kN');
%  



if nargin <4
N=10;
end

cmap=colormap('jet');
     Lmap=size(cmap,1);

tsteps=linspace(t(1),t(end),N+1);

cmap_row_steps=round(1:(Lmap/N):Lmap);

figure





for j=1:N;
    ii=find(t>=tsteps(j) & t <=tsteps(j+1));
    hax(1)=subplot(411);
    h=line(t(ii),x(ii));
    set(h,'color',cmap(cmap_row_steps(j),:))
    grid on
    
    hax(2)=subplot(412)
    h=line(t(ii),y(ii));
    set(h,'color',cmap(cmap_row_steps(j),:))
    grid on
    
    subplot(212)
    hold on
    h=plot(x(ii),y(ii),'.');
    set(h,'color',cmap(cmap_row_steps(j),:))
    hold off
    grid on
end
set(hax(1),'tag','colortrend');
set(hax(2),'tag','colortrend');
connectaxes('+x',hax);
if t(1)>7e5
    subplot(411);datetick;
    subplot(412);datetick;
end

if nargin==6
    subplot(411)
    ylabel(xunits)
    subplot(412)
    ylabel(yunits)
    subplot(212)
    xlabel(xunits)
    ylabel(yunits)
end
fattenplot
