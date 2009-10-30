function AddCoasts(HFig);
%  ADDCOASTS - add coasts

if nargin==0
  HFig=gcf;
end

hax=gca;

load coast

holdstatus=ishold;
hold on
plot(long,lat,'k')

if holdstatus==0
  hold off
end
axes(gca);
