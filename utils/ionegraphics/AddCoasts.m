function AddCoasts(LineWidth,HFig);
%  ADDCOASTS - add coasts
%
%  AddCoasts(0.1)  will add some very thin lines
if nargin==0
  HFig=gcf;
  LineWidth=0.5;
end

if nargin==1
    if LineWidth==round(LineWidth) 
        % this is a figure handle
        HFig=LineWidth;
        LineWidth=0.5;
    else
        HFig=gcf;
    end
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
    hp=plot(long,lat,'k');
    set(hp,'linewidth',LineWidth);
else  
    hp=plotm(lat,long,'k');
    set(hp,'linewidth',LineWidth);
end
set(gcf,'renderer','zbuffer');

if holdstatus==0
  hold off
end
axes(gca);
