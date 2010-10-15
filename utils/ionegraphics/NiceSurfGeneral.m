function OS=NiceSurfGeneral(varargin);
% NICESURFGENERAL
%
% Syntax:
%    NiceSurfGeneral(Data);
%    NiceSurfGeneral(Data,STRUCT);
%    NiceSurfGeneral(Long,Lat,Data,STRUCT);
%    NiceSurfGeneral(DataStruct,STRUCT);
%    NiceSurfGeneral(Data,STRUCT,'propertyname','propertyvalue');
%    NiceSurfGeneral(Data,'propertyname','propertyvalue');
%
%    OS=NiceSurfGeneral(...) returns OS with calculated fields (e.g.
%    coloraxis)
%  Struct can have the following fields [Default]
%
%   NSS.coloraxis=coloraxis
%
%   where coloraxis can have the following forms:
%   [] (empty vector)
%           coloraxis from data minimum to data maximum
%   [f]   where f is between 0 and 1
%           coloraxis from data minimum to 100*f percentile maximum
%           This syntax useful if there are a few outliers
%   [0]     coloraxis from -max(abs(Data)) to +max(abs(Data))
%           This syntax is useful for aligning 0 with the center of a
%           colorbar
%   [-f]  where f is between 0 and 1
%           hybrid of previous two syntaxes.  coloraxis centered on 0, and
%           will extend to +/-  100*f percentile absolute maximum
%           This syntax useful if there are a few outliers in a plot of
%           relative changes.
%   [cmin cmax]
%           coloraxis from cmin to cmax
%
%
%
%   NSS.Units ['']
%   NSS.TitleString
%   NSS.FileName
%   NSS.cmap
%   NSS.LongLatBox
%   NSS.DisplayNotes  - this will be placed on the lower left of graph
%   NSS.Description - this will be saved as metadata within the file
%   NSS.PlotArea='World';
%   NSS.coloraxis=[];
%   NSS.Description='';
%   NSS.DisplayNotes='';
%   NSS.uppermap='white';
%   NSS.lowermap='emblue';
%   NSS.colorbarpercent='off';%
%   NSS.resolution='-r600';%
%   NSS.figfilesave='on';%
%   NSS.plotflag='on';  %allows for calling functions to turn off plotting
%   NSS.fastplot='off'; %downsamples data/turns off printing for fast plots
%   
%  Example
%
%  SystemGlobals
%  S=OpenNetCDF([IoneDataDir '/Crops2000/crops/maize_5min.nc'])
%
%  Area=S.Data(:,:,1);
%  Yield=S.Data(:,:,2);
%   NSS.Units='tons/ha';
%   NSS.TitleString='Yield Maize';
%   NSS.FileName='YieldTestPlot4';
%   NSS.cmap='revsummer'
%   NSS.LongLatBox=[];
%   NSS.coloraxis=[];
%   NSS.LogicalInclude=[];
%   NiceSurfGeneral(Yield,NSS)
%
%   NSS.LongLatBox=[-120 -80 10 35]; %PlotArea takes precedence
%   NSS.PlotArea='World';
%   NSS.coloraxis=[];
%   NSS.Description='';
%   NSS.DisplayNotes='';
%   NSS.uppermap='white';
%   NSS.lowermap='emblue';
%   NSS.colorbarpercent='off';
%
%   NiceSurfGeneral(Yield,NSS)

%
%% preliminaries to handle inputs
if nargin==0
    help(mfilename)
    return
end

arglist=varargin;  %so we can hack this down as we remove arguments

if nargin==1
    % make sure at least two arguments, for less error checking below
    NSS.PlotArea='World';
    arglist{2}=NSS;
end


%possible input syntax:
%    NiceSurf(Data,STRUCT);
%    NiceSurf(Data,STRUCT,'propertyname','propertyvalue');
%    NiceSurf(Data,'propertyname','propertyvalue');
%    NiceSurf(Long,Lat,Data,STRUCT);
%    NiceSurf(Long,Lat,Data,'propertyname','propertyvalue');
%    NiceSurf(Long,Lat,Data,STRUCT,'propertyname','propertyvalue');
%%% where Data can be a matrix or a structure.

%take care of the cases where first argin is a vector.

if min(size(arglist{1}))==1
    Long=arglist{1};
    Lat=arglist{2};
    arglist=arglist(3:end);
end


% now resolve for data to be a structure or a matrix
Data=arglist{1};
if isstruct(Data)
    %    MissingValue=GetMissingValue(Data);
    [Long,Lat,Data,Units,DefaultTitleStr,NoDataStructure]=ExtractDataFromStructure(Data);
    %    Data(Data==MissingValue)=NaN;
else
    [Long,Lat]=InferLongLat(Data);
end


if isstruct(arglist{2})
    NSS=arglist{2};
    if length(arglist)==2
        PropsList=[];
    else
        PropsList=arglist(3:end);
    end
else
    
    NSS=[];
    PropsList=arglist(2:end);
end

for j=1:2:length(PropsList)
    NSS=setfield(NSS,PropsList{j},PropsList{j+1});
end


%% sort through everything passed in ...


ListOfProperties={
    'units','titlestring','filename','cmap','longlatbox','plotarea', ...
    'logicalinclude','coloraxis','displaynotes','description',...
    'uppermap','lowermap','colorbarpercent','resolution',...
    'figfilesave','plotflag','fastplot'};

%% set defaults for these properties
units='';
titlestring='';
filename='';
cmap='summer';
longlatbox=[-180 180 -90 90];
plotarea='';
logicalinclude=[];
coloraxis=[];
displaynotes='';
description='';
uppermap='white';
lowermap='emblue';
colorbarpercent='off';
resolution='-r600';
figfilesave='off';
plotflag='on';
fastplot='off';
%%now pull property values out of structure

a=fieldnames(NSS);
for j=1:length(a)
    ThisProperty=a{j};
    if isempty(strmatch(lower(ThisProperty),lower(ListOfProperties),'exact'))
        ListOfProperties
        error(['Property "' ThisProperty '" not recognized in ' mfilename])
    end
    %disp([ lower(ThisProperty) '=NSS.' ThisProperty ';'])
    eval([ lower(ThisProperty) '=NSS.' ThisProperty ';'])
end

if isequal(plotflag,'off') & nargout==0  %if nargout ~= 0, need to keep going so as to define NSS
    return
end


ylim=pi/2;  % need to initialize variable.
% Now a section to look for PlotArea

if isempty(plotarea)
    %we are done.  keep longlatbox as is.
    PlotAllStates=0;
else
    PlotAllStates=1;
    switch lower(plotarea)
        case 'world'
            longlatbox=[-180 180 -90 90];
            ylim=pi/2;
        case 'europe'
            longlatbox=[-15 65 30 80];
            filename=[filename '_europe'];
            ylim=.51;
        case {'usmexico','usmex'}
            longlatbox=[-130 -60 10 55];
            filename=[filename '_usmexico'];
            ylim=.43;
        case 'africa'
            longlatbox=[-20 60 -35 40];
            filename=[filename '_africa'];
            ylim=.77;
        case 'midwest'
            longlatbox=[-105 -75 25 55];
            filename=[filename '_midwest'];
            ylim=.32;
        case 'tropics'
            longlatbox=[-180 180 -30 30];
            filename=[filename '_tropics'];
            ylim=.32;
        case {'brazil','brasil'}
            longlatbox=[-80 -20 -40 10];
            filename=[filename '_brazil'];
            ylim=.52;
        case {'southamerica'}
            longlatbox=[-80 -20 -40 10];
            filename=[filename '_southamerica'];
            ylim=.52;
        case {'argentina'}
            longlatbox=[-80 -20 -60 -20];
            filename=[filename 'argentina'];
            ylim=.45;
        case {'china'}
            longlatbox=[75 140 15 60];
            filename=[filename '_china'];
            ylim=.42;%.37;%.32;%52
        case {'india'}
            longlatbox=[65 100 5 40];
            filename=[filename '_india'];
            ylim=.35%.32;	    
        case {'indonesia'}
            longlatbox=[90 145 -15 10];
            filename=[filename '_indonesia'];
            ylim=.27;%.32;	    	    
        case {'chinatropical'}
            longlatbox=[80 140 10 35];
            filename=[filename '_chinatropical'];
            ylim=.32;
        case {'mexico'}
            longlatbox=[-125 -80 10 35];
            filename=[filename '_mexico'];
            ylim=.27;%.32;	    
        case {'southafrica'}
            longlatbox=[15 40 -40 -20];
            filename=[filename '_southafrica'];
            ylim=.22;	    
     otherwise
            error(['Don''t recognize plotarea ' plotarea]);
    end
end

%% check class of Data, data conditioning
S=class(Data);

switch S
    case {'double','single'}
        %ok.  do nothing.
    otherwise
        warning(mfilename,'Class of Data variable might cause problems.')
end
Data=double(Data);

ii=find(abs(Data) >= 1e9);
if ~isempty(ii)
    disp([' Found elements >= 1E9.  replacing with NaN. '])
    Data(ii)=NaN;
end


%% Check that logicalinclude is correct size
if ~isempty(logicalinclude)
    if size(logicalinclude)~=size(Data);
        error(['LogicalInclude matrix of wrong size passed to ' mfilename]);
    else
        Data(~logicalinclude)=NaN;
    end
end

%% check to see if fastplot==1
if isequal(fastplot,'on')
    % downsample data if it is 5min
    if length(size(Data,2))<=1080
        disp([' data is 20 min or coarser.  not downsampling.']);
        Data=Data(1:2:end,1:2:end);
        logicalinclude=logicalinclude(1:2:end,1:2:end);
    end
    figfilesave='off';
    filename='';
end

Data=double(Data);



%% colorbars
if length(coloraxis)<2
    
    
    if length(coloraxis==1)
        ii=find(Data~=0  & isfinite(Data));
        tmp01=Data(ii);
        if length(tmp01)==0
            disp(['all finite values are zero'])
            coloraxis=[-1 1];
        else
            if coloraxis==0
                coloraxis=[-(max(abs(tmp01))) (max(abs(tmp01)))]
            else
                f=abs(coloraxis);
                tmp01=sort(tmp01);
                loval=min(tmp01);
                hiaverage=tmp01(round(length(tmp01)*f));
                if coloraxis>0
                    coloraxis=[loval hiaverage];
                else
                    coloraxis=[-hiaverage hiaverage];
                end
            end
        end
    else
        ii=find(isfinite(Data));
        tmp01=Data(ii);
        coloraxis=[min(tmp01) max(tmp01)]
    end
    
    
    % make sure that coloraxis isn't really close to zero but not quite.
    % If so, then pull it down to zero.
    
    c1=coloraxis(1);
    c2=coloraxis(2);
    
    if c1 < (c2-c1)/10
        coloraxis(1)=min(c1,0);
    end
end



%% prepare output data
% do it before turn nan to NoData value.
OS.coloraxis=coloraxis;
OS.Data=Data;


%% Color axis manipulation
cmax=coloraxis(2);
cmin=coloraxis(1);
minstep= (cmax-cmin)*.001;

Data(Data>cmax)=cmax;
Data(cmin>Data)=cmin;



OceanVal=coloraxis(1)-minstep;
NoDataLandVal=coloraxis(2)+minstep;


%Any points off of the land mask must be set to ocean color.
land=LandMaskLogical(Data);
ii=(land==0);
Data(ii)=OceanVal;

% no make no-data points above color map to get 'uppermap' (white)
Data(isnan(Data))=NoDataLandVal;

if isequal(plotflag,'off')   %if nargout ~= 0, need to keep going so as to define NSS
    OS.Data=Data;
   return
end



%% Make graph
IonESurf(Data);

finemap(cmap,lowermap,uppermap);

caxis([(cmin-minstep)  (cmax+minstep)]);
if   PlotAllStates==0;
    AddStates(0.05);
else
    AddStates(0.05,gcf,'all');
end
fud=get(gcf,'UserData');
if fud.MapToolboxFig==1
    gridm
else
    grid on
end
set(gcf,'position',[ 218   618   560   380]);
set(fud.DataAxisHandle,'Visible','off');
set(fud.DataAxisHandle,'Position',[0.00625 .2 0.9875 .7]);
set(fud.ColorbarHandle,'Visible','on');
%set(fud.ColorbarHandle,'Position',[0.1811+.1 0.08 0.6758-.2 0.0568])
drawnow
if fud.MapToolboxFig==0
    set(fud.ColorbarHandle,'Position',[0.0071+.1    0.0822+.02    0.9893-.2    0.0658-.02])
else
    set(fud.ColorbarHandle,'Position',[0.09+.05 0.10 (0.6758-.1+.18) 0.02568])
end

if isequal(colorbarpercent,'on')
    AddColorbarPercent;
end


if ~isequal(longlatbox,[-180 180 -90 90]) & ~isempty(longlatbox)
    
    g1=longlatbox(1);
    g2=longlatbox(2);
    t1=longlatbox(3);
    t2=longlatbox(4);

    if fud.MapToolboxFig==1
        
        trustmatlab=1
        
        if trustmatlab==1
            
            setm(fud.DataAxisHandle,'Origin',...
                [(t1+t2)/2 (g1+g2)/2 0])
            setm(fud.DataAxisHandle,'FLonLimit',[g1 g2]-mean([g1 g2]))
            setm(fud.DataAxisHandle,'FLatLimit',[t1 t2]-mean([t1 t2]))
        else
            setm(fud.DataAxisHandle,'Origin',...
                [0 0 0])
            setm(fud.DataAxisHandle,'FLonLimit',[g1 g2])
            setm(fud.DataAxisHandle,'FLatLimit',[t1 t2])
        end
        
    else
        % no mapping toolbox.  let's make things easy.
        
        axis([g1 g2 t1 t2])
                
    end
    ht=text(0, ylim,titlestring)
else
    ht=text(0,pi/2,titlestring);
    if length(titlestring)>1
        set(ht,'Position',[0 1.635 0]);
    end
end


set(fud.DataAxisHandle,'Visible','off');%again to make it current
%

set(ht,'HorizontalAlignment','center');
set(ht,'FontSize',14)
set(ht,'FontWeight','Bold')


hcbtitle=get(fud.ColorbarHandle,'Title');
set(hcbtitle,'string',[' ' units ' '])
set(hcbtitle,'fontsize',12);
set(hcbtitle,'fontweight','bold');
%cblabel(Units)

%% Was there text for an archival statement on the plot?
if ~isempty(displaynotes)
    hx=axes('position',[.01 .01 .98 .02]);
    ht=text(0,0.5,displaynotes)
    set(hx,'visible','off')
    set(ht,'fontsize',6)
    set(ht,'interpreter','none')
end

hideui
if ~isempty(filename)
    ActualFileName=OutputFig('Force',filename,resolution);
    if isequal(figfilesave,'on')
        hgsave(filename);
    end
    if length(get(allchild(0)))>4
        close(gcf)
    end
end

% now ... if there is a metadata request, open and then resave the file
if ~isempty(description) & ~isequal(fastplot,'on')
    if ~strcmp(ActualFileName(end-3:end),'.png');
        ActualFileName=[ActualFileName '.png'];
    end
    a=imread(ActualFileName);
    imwrite(a,ActualFileName,'Description',description);
end

