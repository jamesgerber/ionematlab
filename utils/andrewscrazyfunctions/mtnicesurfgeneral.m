function OS=mtnicesurfgeneral(varargin);
% MTNICESURFGENERAL - uberplotting program. Much faster than nsg but no
% borders. Not all the UI tools work.
%
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
%   NSS.TitleString   %or NSS.Title
%   NSS.FileName   = if 'on' will use titlestring
%   NSS.cmap
%   NSS.LongLatBox
%   NSS.DisplayNotes  - this will be placed on the lower left of graph
%   NSS.Description - this will be saved as metadata within the file
%   NSS.PlotArea='World';
%   NSS.coloraxis=[];
%   NSS.Description='';
%   NSS.DisplayNotes='';
%   NSS.uppermap='white'; %or nodatacolor
%   NSS.lowermap='emblue'; % or ocean or oceancolor
%   NSS.colorbarpercent='off';
%   NSS.colorbarfinalplus='off';%
%   NSS.colorbarminus='off';%
%   NSS.panoplytriangles=[0 0]; % left/right logical turns on L/R triangle
%   NSS.eastcolorbar='off';%
%   NSS.resolution='-r600';%
%   NSS.figfilesave='on';%
%   NSS.plotflag='on';  %allows for calling functions to turn off plotting
%   NSS.fastplot='off'; %downsamples data/turns off printing for fast plots
%                       % acceptable values 'on', 'halfdegree'
%   NSS.longlatlines='on' %turns lat long grid on or off
%   NSS.plotstates='bricnafta' %adm bounds.
%         {'off','countries','bricnafta','states','gadm0','gadm1','gadm2'}
%   NSS.categorical='off';
%   NSS.categoryranges={};
%   NSS.categoryvalues={};
%   NSS.DataCutoff=9e9;
%   NSS.MakePlotDataFile='off';
%
%
%   Example:
%
%  mtnicesurfgeneral(easyinterp2(magic(15),4320,2160));
%
%
%   See Also:  NiceSurfGeneral IoneSurf ShowUi HideUi FastSurf

% desired changes
%  - fix cvector warning in underlying IonESurf code
%  - when resize a map, keep title visible
%  - when plotarea flag is used, discard extraneous data to make coordinate
%  rotation faster

%% preliminaries to handle inputs
if nargin==0
    help(mfilename)
    return
end

arglist=varargin;  %so we can hack this down as we remove arguments
varargin
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

oldbox=[-180 180 -90 90];

NSS=CorrectCallingSyntax(NSS)


%% sort through everything passed in ...


ListOfProperties={
    'units','titlestring','filename','cmap','longlatbox','plotarea', ...
    'logicalinclude','coloraxis','displaynotes','description',...
    'uppermap','lowermap','colorbarpercent','colorbarfinalplus',...
    'colorbarminus','resolution','longlatlines',...
    'figfilesave','plotflag','fastplot','plotstates','categorical',...
    'categoryranges','categoryvalues','categorycolors','datacutoff',...
    'eastcolorbar','MakePlotDataFile','panoplytriangles','projection'};

%% set defaults for these properties
units='';
titlestring='';
filename='';
cmap='dark_greens_deep';
longlatbox=[-180 180 -90 90];
plotarea='';
logicalinclude=[];
coloraxis=[];
displaynotes='';
description='';
eastcolorbar='off';%
makeplotdatafile='off';
projection='';  %empty is default

datacutoff=9e9;

% new Joanne colors - now set in personalpreferencestemplate
% lowermap=[0.835294118 0.894117647 0.960784314];
% uppermap=[.92 .92 .92];

uppermap=callpersonalpreferences('nodatacolor');
lowermap=callpersonalpreferences('oceancolor');
resolution=callpersonalpreferences('printingres');

colorbarpercent='off';
colorbarfinalplus='off';
colorbarminus='off';
panoplytriangles =[0 0];
figfilesave='off';
plotflag='on';
fastplot='off';
plotstates='bricnafta';
longlatlines='off';
categorical='off';
categoryranges={};
categoryvalues={};
%%now pull property values out of structure


if strcmp(categorical,'on')
    cmap=easyinterp2(cmap,3,length(categoryvalues));
end

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

if isequal(plotflag,'off') & nargout==0  %if nargout ~= 0, need to keep going so as to define OSS
    return
end



%%
%  Now all user input is collected.  We can start changing things in response to
% user-supplied flags
%
% is 'plotarea' specified?
if isempty(plotarea)
    % don't change longlatbox
    PlotAllStates=0;
else
    [longlatbox,filename]=ModifyLongLatBox(plotarea,filename);
    PlotAllStates=1;
end

% was cmap a cell array?
if iscell(cmap)
    cmap=ExpandCellCmap(cmap);
end

% is categoryvalues empty?  make it category values
if ~isempty(categoryranges) & isempty(categoryvalues)
    
    for j=1:length(categoryranges)
        range=categoryranges{j};
        categoryvalues(j)={['[' num2str(range(1)) ' ' num2str(range(2)) ']' ]};
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

ii=find(abs(Data) >= datacutoff);
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
    %   disp(['Turning off saving file ... fastplot is on'])
    %   figfilesave='off';
    %   filename='';
end

%% check to see if fastplot==1
if isequal(fastplot,'halfdegree')
    % downsample data if it is 5min
    if length(size(Data,2))<=1080
        disp([' data is 20 min or coarser.  not downsampling.']);
        Data=Data(1:6:end,1:6:end);
        logicalinclude=logicalinclude(1:6:end,1:6:end);
    end
    %   disp(['Turning off saving file ... fastplot is on'])
    %   figfilesave='off';
    %   filename='';
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
                loaverage=tmp01(round(length(tmp01)*(1-f)));

                if coloraxis>0
                    coloraxis=[loval hiaverage];
                elseif coloraxis==0
                    coloraxis=[-hiaverage hiaverage];
                else
                    coloraxis=[loaverage hiaverage];
                    
                    coloraxis=AMTSmartCAxisLimit([loaverage hiaverage]);
                    cmaptemp=finemap(cmap,'','');
                    cmap=TruncateColorMap(cmaptemp,coloraxis(1),coloraxis(2));                  
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

temp=Data;
if strcmp(categorical,'on')
    coloraxis=[1,length(categoryvalues)];
    for ii=1:length(categoryranges)
        cur=categoryranges{ii};
        temp(Data>=cur(1)&Data<cur(2))=ii;
    end
end

Data=temp;
clear temp


%% Color axis manipulation
cmax=coloraxis(2);
cmin=coloraxis(1);
minstep= (cmax-cmin)*.001;

Data(Data>cmax)=cmax;
Data(cmin>Data)=cmin;

if minstep==0
    minstep=.001;
end

OceanVal=coloraxis(1)-minstep;
NoDataLandVal=coloraxis(2)+minstep;

%Any points off of the land mask must be set to ocean color.
land=LandMaskLogical(Data);
ii=(land==0);
Data(ii)=OceanVal;

% no make no-data points above color map to get 'uppermap' (white)
Data(isnan(Data))=NoDataLandVal;

Data=matrixoffset(Data,-round(((mean(longlatbox(1:2))-mean(oldbox(1:2)))/360)*size(Data,1)),round(((mean(longlatbox(3:4))-mean(oldbox(3:4)))/180)*size(Data,2)));

OS.longlatbox=longlatbox;

OS.ProcessedMapData=Data;
OS.cmap_final=finemap(cmap,lowermap,uppermap);  %don't change unless change finemap call below.
OS.caxis_final=[(cmin-minstep)  (cmax+minstep)];%don't change unless change caxis call below.

if isequal(plotflag,'off')   %if nargout ~= 0, need to keep going so as to define NSS
    return
end

%%%%%  this didn't work because of an incompatibility with AddStates in
%%%%%  IoneSurf.   The idea here was to only plot a part of the globe so as
%%%%%  to make these mappings faster.
% Check to see if lat/long is limited
%if ~isequal(longlatbox,[-180 180 -90 90])
%    [Long,Lat]=InferLongLat(Data);
%    
%    iilong=find(Long >= longlatbox(1) & Long <=longlatbox(2));
%    jjlat=find(Lat >= longlatbox(3) & Lat <=longlatbox(4));
%    
%    IonESurf(Long(iilong),Lat(jjlat),Data(iilong,jjlat));
%    
%else
%    
%end

IonESurf(Data);

%% Change projection

if  ~isequal(projection,'') 
    setm(gca,'mapproj',projection)
end




%% Make graph

finemap(cmap,lowermap,uppermap); % see above
caxis([(cmin-minstep)  (cmax+minstep)]); %don't change unless see above



%% plotstates section

%plotstates
% switch(lower(plotstates))
%     
%     case {'off','none'}
%         % do nothing
%     case {'bric','bricnafta','nafta'}
%         AddStates(0.05,gcf,'bricnafta',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     case {'world','lev0'}
%         AddStates(0.05,gcf,'all',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     case {'gadm0'}
%         AddStates(0.05,gcf,'gadm0',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     case {'gadm1'}
%         AddStates(0.05,gcf,'gadm1',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     otherwise
%         error(['have not yet implemented this in AddStates'])
% end


fud=get(gcf,'UserData');

% let's store the cut-off values

fud.NiceSurfLowerCutoff=(cmin+minstep/2);
fud.NiceSurfUpperCutoff=(cmax-minstep/2);
fud.LongLatBox=longlatbox;
fud.QuickVersion=1;
fud.Inputs=varargin;
set(gcf,'UserData',fud);

if fud.MapToolboxFig==1
    
    
    if strcmp(longlatlines,'off')
        gridm('off');
    else
        gridm
        gridcolor=callpersonalpreferences('latlongcolor');
        gridm('GColor',gridcolor);
    end
else
    grid on
    if strcmp(longlatlines,'off')
        grid off
    end
end

set(gcf,'position',[ 218   618   560   380]);
set(fud.DataAxisHandle,'Visible','off');
set(fud.DataAxisHandle,'Position',[0.00625 .2 0.9875 .7]);
set(fud.ColorbarHandle,'Visible','off');
if strcmp(categorical,'on')
    set(fud.ColorbarHandle,'Visible','off');
end
%set(fud.ColorbarHandle,'Position',[0.1811+.1 0.08 0.6758-.2 0.0568])
drawnow


if isequal(eastcolorbar,'off')
    if fud.MapToolboxFig==0
        set(fud.ColorbarHandle,'Position',[0.0071+.1    0.0822+.02    0.9893-.2    0.0658-.02])
    else
        delx= 0.7558;
        x0= 1/2*(1-delx);
        set(fud.ColorbarHandle,'Position',[x0 0.10 delx 0.02568])
    end
else
    error('haven''t yet implemented eastcolorbar')
end

if isequal(colorbarpercent,'on')
    AddColorbarPercent;
end
if isequal(colorbarfinalplus,'on')
    AddColorbarFinalPlus;
end
if isequal(colorbarminus,'on')
    AddColorbarMinus;
end
if ~isequal(longlatbox,[-180 180 -90 90]) & ~isempty(longlatbox)
    
    g1=longlatbox(1);
    g2=longlatbox(2);
    t1=longlatbox(3);
    t2=longlatbox(4);
    
    if fud.MapToolboxFig==1
        
%         trustmatlab=1
%         
%         
%         if trustmatlab==1
%             
%             setm(fud.DataAxisHandle,'Origin',...
%                 [(t1+t2)/2 (g1+g2)/2 0])
            setm(fud.DataAxisHandle,'FLonLimit',[g1 g2]-mean([g1 g2]))
            setm(fud.DataAxisHandle,'FLatLimit',[t1 t2]-mean([t1 t2]))
%         else
%             setm(fud.DataAxisHandle,'Origin',...
%                 [0 0 0])
%             setm(fud.DataAxisHandle,'FLonLimit',[g1 g2])
%             setm(fud.DataAxisHandle,'FLatLimit',[t1 t2])
%         end
        
    else
        % no mapping toolbox.  let's make things easy.
        
        %axis([g1 g2 t1 t2])
        axis([[g1 g2]-mean([g1 g2]),[t1 t2]-mean([t1 t2])]);
        
    end
    ylim=(t2-t1)/100;
    if ~isempty(titlestring)
    ht=text(0, ylim,titlestring);
    
    UserInterpPreference=callpersonalpreferences('texinterpreter');
    
    set(ht,'interp',UserInterpPreference);
    end
else
    if ~isempty(titlestring)
    ht=text(0,pi/2,titlestring);
    if length(titlestring)>1
        set(ht,'Position',[0 1.635 0]);
    UserInterpPreference=callpersonalpreferences('texinterpreter');
    
    set(ht,'interp',UserInterpPreference);
    end
    end
    
    
    
    
    
    
end


set(fud.DataAxisHandle,'Visible','off');%again to make it current
%
if ~isempty(titlestring)
set(ht,'HorizontalAlignment','center');
set(ht,'FontSize',14)
set(ht,'FontWeight','Bold')
set(ht,'tag','NSGTitleTag')
end

hcbtitle=get(fud.ColorbarHandle,'Title');
set(hcbtitle,'string',[' ' units ' '])
set(hcbtitle,'fontsize',12);
set(hcbtitle,'fontweight','bold');
%cblabel(Units)


%% add panoply triangles
if sum(panoplytriangles) > 0
addpanoplytriangle(panoplytriangles)
end



%% Was there text for an archival statement on the plot?
if ~isempty(displaynotes)
    hx=axes('position',[.01 .01 .98 .02]);
    ht=text(0,0.5,displaynotes)
    set(hx,'visible','off')
    set(ht,'fontsize',6)
        UserInterpPreference=callpersonalpreferences('texinterpreter');
    
    set(ht,'interp',UserInterpPreference);
end

hideui




if strcmp(categorical,'on')
    bb = bar(rand(length(categoryvalues),length(categoryvalues)),'stacked'); hold on
    legh=legend(bb,categoryvalues,'Location','SouthWest');
    hlegt=get(legh,'title');
    set(hlegt,'string',units);
    set(bb,'Visi','off')
    set(legh,'position',[0.4362 0.1938 0.3188 0.1865])
end

%% did user want to print?

if isequal(filename,'on')
    filename=titlestring;
end


MaxNumFigs=callpersonalpreferences('maxnumfigsNSG');

% 
% switch(lower(plotstates))
%     
%     case {'off','none'}
%         % do nothing
%     case {'bric','bricnafta','nafta'}
%         AddStates(0.05,gcf,'bricnafta',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     case {'world','lev0'}
%         AddStates(0.05,gcf,'all',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     case {'gadm0'}
%         AddStates(0.05,gcf,'gadm0',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%     case {'gadm1'}
%        AddStates(0.05,gcf,'gadm1',-mean(longlatbox(3:4)),-mean(longlatbox(1:2)));
%      otherwise
%        error(['have not yet implemented this in AddStates'])
% end


OS.Data=single(OS.Data);
OS.cmap=cmap;
ActualFileName='nicesurfoutput.png';
if ~isempty(filename)
    ActualFileName=OutputFig('Force',filename,resolution);

    FN=fixextension(ActualFileName,'.png')
    %save to disk
    if isequal(makeplotdatafile,'yes') | isequal(makeplotdatafile,'on')
        save([strrep(FN,'.png','') '_SavedFigureData'],'OS','NSS')
    end
    if isequal(figfilesave,'on')
        hgsave(filename);
    end
    if length(get(allchild(0)))>MaxNumFigs
        close(gcf)
    end
end
if ~strcmp(ActualFileName(end-3:end),'.png');
    ActualFileName=[ActualFileName '.png'];
end

% now ... if there is a metadata request, open and then resave the file
if ~isempty(description) & ~isequal(fastplot,'on')
    centerfigure(ActualFileName);
    a=imread(ActualFileName);
    imwrite(a,ActualFileName,'Description',description);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ModifyLongLatBox     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [longlatbox,filename]=ModifyLongLatBox(plotarea,filename);


switch lower(plotarea)
    case 'world'
        longlatbox=[-180 180 -90 90];
        %            ylim=pi/2;
    case 'europe'
        longlatbox=[-15 65 30 80];
        filename=[filename '_europe'];
        %            ylim=.51;
    case {'usmexico','usmex'}
        longlatbox=[-130 -60 10 55];
        filename=[filename '_usmexico'];
        %            ylim=.43;
    case {'nafta'}
        longlatbox=[-130 -60 10 60];
        filename=[filename '_nafta'];
        %            ylim=.43;
    case 'africa'
        longlatbox=[-20 60 -35 40];
        filename=[filename '_africa'];
        %            ylim=.77;
    case 'midwest'
        longlatbox=[-105 -75 25 55];
        filename=[filename '_midwest'];
        %            ylim=.32;
    case 'tropics'
        longlatbox=[-180 180 -30 30];
        filename=[filename '_tropics'];
        %            ylim=.32;
    case {'brazil','brasil'}
        longlatbox=[-80 -20 -40 10];
        filename=[filename '_brazil'];
        %            ylim=.52;
    case {'southamerica'}
        longlatbox=[-80 -20 -40 10];
        filename=[filename '_southamerica'];
        %            ylim=.52;
    case {'argentina'}
        longlatbox=[-80 -20 -60 -20];
        filename=[filename 'argentina'];
        %            ylim=.45;
    case {'china'}
        longlatbox=[75 140 15 60];
        filename=[filename '_china'];
        %            ylim=.42;%.37;%.32;%52
    case {'india'}
        longlatbox=[65 100 5 40];
        filename=[filename '_india'];
        %            ylim=.35%.32;
    case {'indonesia'}
        longlatbox=[90 145 -15 10];
        filename=[filename '_indonesia'];
        %            ylim=.27;%.32;
    case {'chinatropical'}
        longlatbox=[80 140 10 35];
        filename=[filename '_chinatropical'];
        %            ylim=.32;
    case {'mexico'}
        longlatbox=[-125 -80 10 35];
        filename=[filename '_mexico'];
        %            ylim=.27;%.32;
    case {'southafrica'}
        longlatbox=[15 40 -40 -20];
        filename=[filename '_southafrica'];
    case {'southeastasia'}
        longlatbox=[90 150 -15 +30];
        filename=[filename 'southeastasia'];
        %            ylim=.22;
    otherwise
        error(['Don''t recognize plotarea ' plotarea]);
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CorrectCallingSyntax     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function NSS=CorrectCallingSyntax(NSS)
% in case user used wrong calling syntax, correct

a=fieldnames(NSS);

for j=1:length(a)
    
    ThisProperty=a{j};
    ThisValue=getfield(NSS,a{j});
    switch lower(ThisProperty)
        case {'title','titlestr'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'titlestring',ThisValue);
        case {'colormap'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'cmap',ThisValue);
        case {'caxis'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'coloraxis',ThisValue);
        case {'ocean','oceancolor','lowercolor'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'lowermap',ThisValue);
        case {'nodata','nodatacolor','uppercolor'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'uppermap',ThisValue);
        case {'fast','quick','quickplot'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'fastplot',ThisValue);
        case {'addcolorbarfinalplus','colorbarplus'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'colorbarfinalplus',ThisValue);
        case {'addcolorbarminus','colorbarfinalminus'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'colorbarminus',ThisValue);
           case {'triangles','froufrou'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'panoplytriangles',ThisValue); 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CorrectCallingSyntax     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newcmap=ExpandCellCmap(cmap);

for j=1:length(cmap)
    thiselement=cmap{j};
    if ~ischar(thiselement)
        newcmap(j,:)=thiselement(:);
    else
        switch thiselement  %it's the name of a color
            case {'r','red'}
                vec=[1 0 0];
            case {'m','magenta','mag'}
                vec=[1 0 1];
            case {'k','black'}
                vec=[0 0 0];
            case {'c','cyan'}
                vec=[0 1 1];
            case {'y','yellow'}
                vec=[1 1 0];
            case {'maroon'}
                vec=[.5 0 0];
            case {'purple'}
                vec=[.5 0 .5];
            case {'b','blue'}
                vec=[0 0 1];
            case 'navy'
                vec=[0 0 .5];
            case 'teal'
                vec=[0 0.5 .5];
            case {'g','green'}
                vec=[0 1 0];
            case 'lime'
                vec=[50 205 50]/255;
        end
        newcmap(j,:)=vec(:);
    end
end

