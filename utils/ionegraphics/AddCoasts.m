function AddCoasts(HFig);
%  ADDCOASTS - add coasts

if nargin==0
  HFig=gcf;
end

hax=gca;

SystemGlobals

try
    load(ADMINBOUNDARY_VECTORMAP)
catch   
    load coast
end

holdstatus=ishold;
hold on

try
    CanMap=CheckForMappingToolbox;
catch
    disp(['problem with Mapping Toolbox check in ' mfilename]);
    CanMap=0;
end

if CanMap==0
    hp=plot(long+.01,lat+.01,'w')
    hp=plot(long,lat,'k')
else  
    hp=plotm(lat,long,'k');
end
set(gcf,'renderer','zbuffer');

if holdstatus==0
  hold off
end
axes(gca);
