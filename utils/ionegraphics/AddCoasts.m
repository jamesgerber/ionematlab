function AddCoasts(HFig);
%  ADDCOASTS - add coasts

if nargin==0
  HFig=gcf;
end

hax=gca;

load coast

holdstatus=ishold;
hold on

try
    CanMap=CheckForMappingToolbox;
catch
    disp(['problem with Mapping Toolbox check in ' mfilename]);
    CanMap=0;
end

if CanMap==0
    plot(long,lat,'k')
else
    disp(['do not know how to add a coast map'])
%    [x,y]=mfwdtran(lat,long);
%    plotm(long*(pi/180),lat*(pi/90),'k');
%    plotm(y*180/pi,x*180/pi,'k');
end

if holdstatus==0
  hold off
end
axes(gca);
