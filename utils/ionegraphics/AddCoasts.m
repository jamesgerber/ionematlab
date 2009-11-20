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
    plot(long,lat,'m')
else  
    plotm(lat,long,'m');
end

if holdstatus==0
  hold off
end
axes(gca);
