function AddCoasts(LineWidth,HFig);
%  ADDCOASTS - add coasts
%
%  AddCoasts(0.1)  will add some very thin lines
%
%  AddCoasts(N) where N is an integer will add lines of default thickness
%  (0.5) to figure N.   [This was added for backwards compatibility]
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
    
    if LineWidth <0.5
        Countries=load(WORLDCOUNTRIES_LEVEL0_HIRES);
        States=load(WORLDCOUNTRIES_BRIC_NAFTASTATES_VECTORMAP_HIRES);
    else
        Countries=load(WORLDCOUNTRIES_LEVEL0_HIRES);
        States=load(WORLDCOUNTRIES_BRIC_NAFTASTATES_VECTORMAP_HIRES);
    end
catch  
        disp(['did not find system vectormap'])
        disp(['loading default matlab coasts'])
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
    hp=plot(States.long,States.lat);
    set(hp,'linewidth',LineWidth,'Color',[.1 .1 .1]*6);
    hp=plot(Countries.long,Countries.lat,'k');
    set(hp,'linewidth',LineWidth)
else  
    hp=plotm(States.lat,States.long,'k');
    set(hp,'linewidth',LineWidth,'Color',[.1 .1 .1]*6);
    hp=plotm(Countries.lat,Countries.long,'k');
    set(hp,'linewidth',LineWidth);
end
set(gcf,'renderer','zbuffer');

if holdstatus==0
  hold off
end
axes(gca);