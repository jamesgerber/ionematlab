function AddStates(LineWidth,HFig,AllStates);
%  ADDSTATES - add country boundaries and some state boundaries
%
%  AddStates(0.1)  will add some very thin lines
%
%  AddStates(N) where N is an integer will add lines of default thickness
%  (0.5) to figure N.   [This was added for backwards compatibility]
if nargin==0
    HFig=gcf;
    LineWidth=0.5;
    AllStates='bricnafta';
end

if nargin==1
    if LineWidth==round(LineWidth)
        % this is a figure handle
        HFig=LineWidth;
        LineWidth=0.5;
    else
        HFig=gcf;
    end
    AllStates='bricnafta';
end

if nargin==2
    AllStates='bricnafta';
end


switch lower(AllStates)
    case {'bric','bricnafta'}
        AllStatesFlag=0;
    case {'all','world'};
        AllStatesFlag=1;
end


hax=gca;

SystemGlobals

try
    
    if AllStatesFlag==0
        Countries=load(WORLDCOUNTRIES_LEVEL0_HIRES);
        States=load(WORLDCOUNTRIES_BRIC_NAFTASTATES_VECTORMAP_HIRES);
    else
        Countries=load(WORLDCOUNTRIES_LEVEL0_HIRES);
        States=load(WORLDCOUNTRIES_LEVEL1_HIRES);
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

%if CanMap==0
if ~ismap(gca)
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
