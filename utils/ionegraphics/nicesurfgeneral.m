function OS=NiceSurfGeneral(varargin);
% NICESURFGENERAL - uberplotting program
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
%   [f f] where f is between 0 and 1 (same value repeated) go from -%ile to
%   +%ile
%
%
%
%   NSS.Units ['']
%   NSS.TitleString   %or NSS.Title
%   NSS.FileName   = if 'on' will use titlestring
%                    if 'dirname/', then will use titlestring and
%                    place in dirname
%   NSS.cmap
%   NSS.LongLatBox
%   NSS.DisplayNotes  - this will be placed on the lower left of graph
%   NSS.Description - this will be saved as metadata within the file
%   NSS.PlotArea='World';  % can be a country name, or ISO code(e.g. USA)
%   NSS.coloraxis=[];
%   NSS.Description='';
%   NSS.DisplayNotes='';
%   NSS.uppermap='white'; %or nodatacolor
%   NSS.lowermap='emblue'; % or ocean or oceancolor
%   NSS.colorbarpercent='off';
%   NSS.colorbarfinalplus='off';%
%   NSS.colorbarminus='off';%
%   NSS.cbarvisible='on';
%   NSS.panoplytriangles=[0 0]; % left/right logical turns on L/R triangle
%   NSS.panoplytriangles=[0 0 0 .4 .8 .3]; % no left triangle, right has
%   RGB pair [.4 .8 .3]
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
%   NSS.separatecatlegend='no';
%   NSS.DataCutoff=9e9;
%   NSS.MakePlotDataFile='off';
%   NSS.NewPlotAreaMethod='0'
%   NSS.font
%   NSS.statewidth=.2;
%   NSS.userinterppreference='tex'
%   NSS.FrameLimitsVector=[-180 180 -90 90];
%   NSS.FrameOff=
%   NSS.sink='';
%   NSS.sink='nonagplaces';  % note that this goes well with NSS.states='agplaces'
%
%  Example
%
%  S=OpenNetCDF([iddstring '/Crops2000/crops/maize_5min.nc'])
%
%  Area=S.Data(:,:,1);
%  Yield=S.Data(:,:,2);
%   NSS.Units='tons/ha';
%   NSS.TitleString='Yield Maize';
%   NSS.FileName='YieldTestPlot4';
%   NSS.cmap='orange_white_purple_deep';
%   NSS.caxis=[.98];
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
%   NSS.projection='';
%   NSS.projection='hatano';
%
%
%   NSS.modifycolormap='stretch';
%   NSS.stretchcolormapcentervalue=0;
%
%   NiceSurfGeneral(Yield,NSS)
%
%   NSS.cbarvisible='off';
%
%   Example:
%
%  S=OpenNetCDF([iddstring '/Crops2000/crops/maize_5min.nc'])
%
%  Area=S.Data(:,:,1);
%  Yield=S.Data(:,:,2);
%   NSS.Units='tons/ha';
%   NSS.categorical='on';
%   NSS.categoryranges={[0 4],[4 6],[6 8],[8 20]}
%   NSS.cmap={'lime',[0 .3 .8],'b','magenta'};
%   NiceSurfGeneral(Yield,NSS);
%  %or%
%   NSS.categoryvalues={'[0 4]','[4 6]','[6 8]','[8 20]'}  
%   NSS.cmap='revsummer'
%      NSS.separatecatlegend='yes';
%   NiceSurfGeneral(Yield,NSS);
%
%   Syntax for getting coloraxis.
%   OSS=NiceSurfGeneral(DATA,'coloraxis',[.99],'plotflag','off')
%   OSS will contain field coloraxis, and no plot will be made.
%
%
%   See Also:  IoneSurf ShowUi HideUI FastSurf

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



if nargin==1
    % make sure at least two arguments, for less error checking below
    NSS.PlotArea='World';
    % also, if only 1 arg in, we are probably just using this in
    % exploratory mode.  So, try to guess a title, and put in a 'showui' at
    % the end.
    showuiattheend=1;
    NSS.TitleString=inputname(1);
    
    arglist{2}=NSS;

    
else
    showuiattheend=0;
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
    switch numel(arglist{1})
        case 3237023
            % landmasklogical
            x=datablank(NaN);
            x(landmasklogical)=arglist{1};
            
            arglist{1}=x;
        case 920953
            %cropmasklogical
            x=datablank(NaN);
            x(cropmasklogical)=arglist{1};
            arglist{1}=x;
        otherwise
            %assume long/lat
            Long=arglist{1};
            Lat=arglist{2};
            arglist=arglist(3:end);
    end
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

if (size(Data,1)~=4320||size(Data,2)~=2160)
    [bLong,bLat]=InferLongLat(zeros(4320,2160));
    mergedata(zeros(4320,2160),bLong,bLat,Data,Long,Lat);
    longlatbox=[min(Long) max(Long) min(Lat) max(Lat)];
end

%%% the following logic is awful ... but my joint if conditional statement
%%% was crashing so i put in this monstrosity.
if length(arglist)==1
    
    NSS.PlotArea='World';
    PropsList=arglist(2:end);
    
else
    
    if isstruct(arglist{2})
        NSS=arglist{2};
        if length(arglist)==2
            PropsList=[];
        else
            PropsList=arglist(3:end);
        end
    else
        
    NSS.PlotArea='World';
        PropsList=arglist(2:end);
    end
end


for j=1:2:length(PropsList)
    NSS=setfield(NSS,PropsList{j},PropsList{j+1});
end

if ~isempty(NSS)
    NSS=CorrectCallingSyntax(NSS);
end

%% sort through everything passed in ...

ListOfProperties={
    'units','titlestring','filename','cmap','longlatbox','plotarea', ...
    'logicalinclude','coloraxis','displaynotes','description',...
    'uppermap','lowermap','colorbarpercent','colorbarfinalplus',...
    'colorbarminus','resolution','longlatlines','separatecatlegend'...
    'figfilesave','plotflag','fastplot','plotstates','categorical',...
    'categoryranges','categoryvalues','categorycolors','datacutoff',...
    'eastcolorbar','makeplotdatafile','panoplytriangles','projection'...
    'cbarvisible','transparent','textcolor','newplotareamethod','font',...
    'statewidth','gridcolor','userinterppreference','maxnumfigs','framelimitsvector',...
    'sink','modifycolormap','stretchcolormapcentervalue'};
ListOfProperties=unique(ListOfProperties);

%% set defaults for these properties
units='';
titlestring=' ';
filename='';
cmap='jet';
longlatbox=[-180 180 -90 90];
plotarea='';
logicalinclude=[];
coloraxis=[];
displaynotes='';
description='';
eastcolorbar='off';%
makeplotdatafile='off';
cbarvisible='on';
projection='';  %empty is default
newplotareamethod=1;
statewidth=.1;
datacutoff=9e9;
separatecatlegend='no';
FrameLimitsVector=[-180 180 -90 90];
sink='none'; 
modifycolormap='none';
stretchcolormapcentervalue=0;
%   NSS.modifycolormap='stretch';

% new Joanne colors - now set in personalpreferencestemplate
% lowermap=[0.835294118 0.894117647 0.960784314];
% uppermap=[.92 .92 .92];

uppermap=callpersonalpreferences('nodatacolor');
lowermap=callpersonalpreferences('oceancolor');
resolution=callpersonalpreferences('printingres');
gridcolor=callpersonalpreferences('latlongcolor');
userinterppreference=callpersonalpreferences('texinterpreter');
maxnumfigs=callpersonalpreferences('maxnumfigsNSG');

colorbarpercent='off';
colorbarfinalplus='off';
colorbarminus='off';
panoplytriangles =[0 0];
figfilesave='off';
plotflag='on';
fastplot='off';
plotstates='bricnafta';
longlatlines='on';
categorical='off';
categoryranges={};
categoryvalues={};
transparent=0;
font='';
textcolor=[0 0 0];
%%now pull property values out of structure


if strcmp(categorical,'on')
    cmap=EasyInterp2(cmap,3,length(categoryvalues));
end

a=fieldnames(NSS);




for j=1:length(a)
    ThisProperty=a{j};
    if isempty(strmatch(lower(ThisProperty),lower(ListOfProperties),'exact'))
        ListOfProperties
        display(['Property "' ThisProperty '" not recognized in ' mfilename])
    end
    %disp([ lower(ThisProperty) '=NSS.' ThisProperty ';'])
    eval([ lower(ThisProperty) '=NSS.' ThisProperty ';'])
    
    % STUPID STUPID STUPID STUPID FIGURE OUT BETTER APPROACH LATER
    eval([ ThisProperty '=NSS.' ThisProperty ';'])
    % WE DON'T NEED 2 COPIES OF EVERY VARIABLE BUT SOME OF THE VARIABLES
    % ARE NOT LOWERCASE AND THERE'S NO GOOD WAY TO TELL WHICH ARE
end

if isequal(plotflag,'off') & nargout==0  %if nargout ~= 0, need to keep going so as to define OSS
    if showuiattheend ==1
        showui
    end
    return
end



%%
%  Now all user input is collected.  We can start changing things in response to
% user-supplied flags


if isequal(filename,'on')
    tstemp=titlestring
    filename=makesafestring(tstemp);
end

if ~isempty(filename) & isequal(filename(end),filesep)
        tstemp=titlestring
%     if isequal(tstemp(end),' ')
%         tstemp=tstemp(1:end-1);
%     end
%     if isequal(tstemp(end),'.')
%         tstemp=titlesttstempring(1:end-1);
%     end
    filename=[filename makesafestring(tstemp)];
end


% is 'plotarea' specified?
if isempty(plotarea)
    % don't change longlatbox
    PlotAllStates=0;
else
    if ischar(plotarea)
        [longlatbox,filename]=ModifyLongLatBox(plotarea,filename);
    else
        longlatbox=plotarea;
        filename=[filename '_latlong' makesafestring(num2str(plotarea))];
    end
        
    PlotAllStates=1;
end

% was cmap a cell array?
if iscell(cmap)
    cmap=ExpandCellCmap(cmap);
end

% if categoryranges is a set of integers, then special case.  build
% category values

if ~iscell(categoryranges)
    disp(['category ranges non-char']);
    cr=categoryranges;
    clear categoryranges;  % now make it into a cell array, so clear it.
    del=min(diff(cr));
    
    if isempty(categoryvalues)
       
        for j=1:length(cr);
            
            categoryranges{j}=[cr(j)-del/10 cr(j)+del/10];
            categoryvalues{j}=num2str(cr(j));
        end
    else
        for j=1:length(cr);
            
            categoryranges{j}=[cr(j)-del/10 cr(j)+del/10];
        end
        
    end
    
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

% if length(coloraxis)==2 & length(unique(coloraxis))==1
%     
%     f=unique(abs(coloraxis));
% 

if isequal(lower(modifycolormap),'stretch');
   % ok ... user wants to stretch colormap.   

    if length(coloraxis)<2
        ii=find(isfinite(Data));
        tmp01=Data(ii);
        coloraxis=[min(tmp01) max(tmp01)]
    end
    cmap=StretchColorMap(cmap,coloraxis(1),coloraxis(2),stretchcolormapcentervalue);

    % this ugly bit of code catches a problem below.  need coloraxes to get
    % cmap, but certain 1-element values of cmap which act as flags lead to
    % code below for which you need to define both below.  it would be much
    % better to move StretchColorMap as well as TruncateColorMap below the
    % length(coloraxis)<2 code.   #nicetodo ...
end


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
                    
                    if loaverage>0 & hiaverage>0
                        coloraxis=[loaverage hiaverage];
                    else                    
                        coloraxis=AMTSmartCAxisLimit([loaverage hiaverage]);
                        cmaptemp=finemap(cmap,'','');
                        cmap=TruncateColorMap(cmaptemp,coloraxis(1),coloraxis(2));
                    end
                end
            end
        end
    else
        ii=find(isfinite(Data));
        tmp01=Data(ii);
        coloraxis=[min(tmp01) max(tmp01)]
    end
    
    
    if isempty(coloraxis)
        disp(['Coloraxis is empty.  presumably data is all NaN. ' ...
            'using arbitrary axis so code can continue.']);
        coloraxis=[0 1];
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

temp=Data*NaN;
if strcmp(categorical,'on')
    coloraxis=[1,length(categoryvalues)];
    for ii=1:length(categoryranges)
        cur=categoryranges{ii};
        temp(Data>=cur(1)&Data<cur(2))=ii;
    end
Data=temp;
clear temp


end

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
land=landmasklogical(Data);
ii=(land==0);
size(ii);
size(Data);
ii=EasyInterp2(ii,size(Data,1),size(Data,2),'nearest');
Data(ii)=OceanVal;

switch lower(sink)
    case {'','default','none'}
        % do nothing
    case {'nonagplaces'}
        mm=AgriMaskLogical;
        mm=~mm;
        ii=EasyInterp2(mm,size(Data,1),size(Data,2),'nearest');
        Data(ii)=OceanVal;
end


% now make no-data points above color map to get 'uppermap' (white)
Data(isnan(Data))=NoDataLandVal;

%% test code to do crazy things with panoply triangles
if length(panoplytriangles)==6
    cmap=finemap(cmap,'','');
    
    if sum(panoplytriangles(1:3))>0
        % user has specified something for the left triangle
        cmap=[panoplytriangles(1:3);panoplytriangles(1:3);cmap];
    end
    
    
    if sum(panoplytriangles(4:6))>0
        % user has specified something for the left triangle
        cmap=[cmap;panoplytriangles(4:6);panoplytriangles(4:6);...
            panoplytriangles(4:6);panoplytriangles(4:6)];
    end
end

%%




OS.ProcessedMapData=Data;
OS.cmap_final=finemap(cmap,lowermap,uppermap);  %don't change unless change finemap call below.
OS.caxis_final=[(cmin-minstep)  (cmax+minstep)];%don't change unless change caxis call below.

if isequal(plotflag,'off')   %if nargout ~= 0, need to keep going so as to define NSS
    if showuiattheend ==1
        showui
    end
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

OS.axishandle=gca;



%% Make graph

finemap(cmap,lowermap,uppermap); % see above
caxis([(cmin-minstep)  (cmax+minstep)]); %don't change unless see above



%% plotstates section

%plotstates
switch(lower(plotstates))
    
    case {'off','none'}
        % do nothing
    case {'bric','bricnafta','nafta'}
        AddStates(statewidth,gcf,'bricnafta');
    case {'world','lev0'}
        AddStates(statewidth,gcf,'all');
    case {'gadm0','countries'}
        AddStates(statewidth,gcf,'gadm0');
    case {'gadm1'}
        AddStates(statewidth,gcf,'gadm1');
    case {'agplaces'}
        AddStates(statewidth,gcf,'AgPlaces');

    otherwise
        error(['have not yet implemented this in AddStates'])
end


fud=get(gcf,'UserData');

% let's store the cut-off values

fud.NiceSurfLowerCutoff=(cmin-minstep/2);
fud.NiceSurfUpperCutoff=(cmax+minstep/2);
fud.QuickVersion=0;
fud.transparent=transparent;

if fud.MapToolboxFig==1
    
    
    if strcmp(longlatlines,'off')
        gridm('off');
    else
        gridm

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
set(fud.ColorbarHandle,'Visible',cbarvisible);
if strcmp(categorical,'on')
    set(fud.ColorbarHandle,'Visible','off');
end
OS.colorbarhandle=fud.ColorbarHandle;
%set(fud.ColorbarHandle,'Position',[0.1811+.1 0.08 0.6758-.2 0.0568])
drawnow


if isequal(eastcolorbar,'off')
    if fud.MapToolboxFig==0
        set(fud.ColorbarHandle,'Position',[0.0071+.1    0.0822+.02    0.9893-.2    0.0658-.02]);
    else
        delx= 0.7558;
        x0= 1/2*(1-delx);
        set(fud.ColorbarHandle,'Position',[x0 0.10 delx 0.02568],'XColor',textcolor,'YColor',textcolor)
        secondbar= colorbar('Location','South','XTickLabel',...
            {''});
        set(secondbar,'Position',[x0 0.10 delx 0.02568],'YColor',[0 0 0])
        set(secondbar,'Visible','off')
    end
else
    if fud.MapToolboxFig==0
        set(fud.DataAxisHandle,'Position',[0.00625 .2 0.8875 .7]);
        set(fud.ColorbarHandle,'Location','East');
        set(fud.ColorbarHandle,'Position',[0.9218 0.2237 0.0357 0.6500]);
    else
        error(' haven''t yet implemented this unless mappingoff')
        delx= 0.7558;
        x0= 1/2*(1-delx);
        set(fud.ColorbarHandle,'Position',[x0 0.10 delx 0.02568],'XColor',textcolor,'YColor',textcolor)
        secondbar= colorbar('Location','South','XTickLabel',...
            {''});
        set(secondbar,'Position',[x0 0.10 delx 0.02568],'YColor',[0 0 0])
        set(secondbar,'Visible','off')
    end
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

if isfield(fud,'MapHandle');
    mapaxishandle=fud.MapHandle;
    OS.mapaxishandle=mapaxishandle;
else
    OS.mapaxishandle=-1;
end
%maud=get(mapaxishandle,'UserData');  %mapaxisuserdata
%maud.maplatlimit=FrameLimitsVector(3:4);
%maud.maplonlimit=FrameLimitsVector(1:2);
if fud.MapToolboxFig==1
    setm(mapaxishandle,'maplatlimit',FrameLimitsVector(3:4));
    setm(mapaxishandle,'maplonlimit',FrameLimitsVector(1:2));
end


fud.titlestring=titlestring;
fud.units=units;
set(gcf,'UserData',fud);
if ~isequal(longlatbox,[-180 180 -90 90]) & ~isempty(longlatbox)
    
    g1=longlatbox(1);
    g2=longlatbox(2);
    t1=longlatbox(3);
    t2=longlatbox(4);
    
    if fud.MapToolboxFig==1
        
        trustmatlab=1;
        if newplotareamethod==0
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
            %setm(fud.DataAxisHandle,'Origin',...
            %    [(t1+t2)/2 (g1+g2)/2 0])
           ht= PropagateLimits('Import',gcf, [g1 g2]*pi/180, [t1 t2]*pi/180)
            
            
        end
        
    else
        % no mapping toolbox.  let's make things easy.
        
        axis([g1 g2 t1 t2])
        
    end
    %    ylim=(t2-t1)/100;
    %    ht=text(0,ylim,titlestring);
 %   ht=text(mean([g1 g2]*pi/180),t2*pi/180 + mean([t1 t2]/75)*pi/180,titlestring);
 %set(ht,'HorizontalAlignment','center');
    
    
 %   UserInterpPreference=callpersonalpreferences('texinterpreter');
    
 %   set(ht,'interp',UserInterpPreference);
else
    ht=text(0,pi/2,titlestring);
    if length(titlestring)>1
        set(ht,'Position',[0 1.635 0]);
    set(ht,'interp',userinterppreference);
    end
end


fud.titlehandle=ht;
set(gcf,'UserData',fud);

set(fud.DataAxisHandle,'Visible','off');%again to make it current
%

set(ht,'HorizontalAlignment','center');
set(ht,'FontSize',14)
set(ht,'FontWeight','Bold')
set(ht,'tag','NSGTitleTag')
if (~isempty(font))
    set(ht,'FontName',font);
end
set(ht,'Color',textcolor)

hcbtitle=get(fud.ColorbarHandle,'Title');
set(hcbtitle,'string',[' ' units ' '])
set(hcbtitle,'fontsize',12);
set(hcbtitle,'fontweight','bold');
if (~isempty(font))
    set(hcbtitle,'FontName',font);
end
set(hcbtitle,'Color',textcolor);
%cblabel(Units)


%% add panoply triangles
if sum(panoplytriangles) > 0
    pthandles=addpanoplytriangle(panoplytriangles, cmap)
else
    pthandles=[-1 -1];
end



%% Was there text for an archival statement on the plot?
if ~isempty(displaynotes)
    mainaxes=gca;
    hx=axes('position',[.01 .01 .98 .02]);
    ht=text(0,0.5,displaynotes)
    set(hx,'visible','off')
    set(ht,'fontsize',6)
    
    set(ht,'interp',userinterppreference);
    axes(mainaxes);
end

HideUI



%% did user want to print?




if strcmp(categorical,'on')
    
    if strcmp(separatecatlegend,'yes')
        Hfig=gcf;
        Hlegendfig=figure;
        bb = bar(rand(length(categoryvalues),length(categoryvalues)),'stacked'); hold on
        colormap(OS.cmap_final(2:end-1,:));  
        %need to skip first/last value because those are the ocean/no data colors
        
        legh=legend(bb,categoryvalues,3);      
        hlegt=get(legh,'title');
        set(hlegt,'string',units);
        set(bb,'Visi','off')
        set(gca,'Visible','off','Position',[.13 .11 .45 .25])
        set(Hlegendfig,'position',[442   457   260   240])
        if ~isempty(filename)
            OutputFig('Force',[strrep(filename,'.png','') '_categorical_legend'],resolution);
        end
        figure(Hfig);  % make previous figure current.

    else
        
        bb = bar(rand(length(categoryvalues),length(categoryvalues)),'stacked'); hold on
        legh=legend(bb,categoryvalues,3);
        
        [VER DATESTR] = version();
        if str2num(DATESTR(end-3:end))<2014
            
            hlegt=get(legh,'title');
            set(hlegt,'string',units);
            
        else
            legh.String=units;
        end
        
        set(bb,'Visi','off')
        
        
        set(legh,'position',[0.4362 0.1938 0.3188 0.1865])
    end
end




OS.Data=single(OS.Data);
OS.cmap=cmap;
OS.panoplytrianglehandlepatches=pthandles;


if ~isempty(filename)
    ActualFileName=OutputFig('Force',filename,resolution);
    OS.ActualFileName=ActualFileName;
    FN=fixextension(ActualFileName,'.png')
    %save to disk
    if isequal(makeplotdatafile,'yes') | isequal(makeplotdatafile,'on')
        if (isstr(cmap))
            eval(['cmap=''' cmap ''';']);
        end
        NSS.cmap=cmap;
        NSS.uppermap=uppermap;
        NSS.lowermap=lowermap;
        NSS.resolution=resolution;
        NSS.gridcolor=gridcolor;
        NSS.userinterppreference=userinterppreference;
        NSS.maxnumfigs=maxnumfigs;
        save([strrep(FN,'.png','') '_SavedFigureData'],'OS','NSS')
    end
    if isequal(figfilesave,'on')
        hgsave(MakeSafeString(filename,1));
    end
    if length(get(allchild(0)))>maxnumfigs
        close(gcf)
    end
end

% now ... if there is a metadata request, open and then resave the file
if ~isempty(description) & ~isequal(fastplot,'on')
    if ~strcmp(ActualFileName(end-3:end),'.png');
        ActualFileName=[ActualFileName '.'];
    end
    a=imread(ActualFileName);
    imwrite(a,ActualFileName,'Description',description);
end

    if showuiattheend ==1
        showui
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
    case 'westerneurope'
        longlatbox=[-10 25 35 50];
        filename=[filename '_westerneurope'];
        %            ylim=.51;
    case 'westeurope'
        longlatbox=[-10 20 30 50];
        filename=[filename '_westeurope'];
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
        longlatbox=[-95 -55 25 55];
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
   case {'chaco'}
        longlatbox=[-70 -30 -35 -15];
        filename=[filename 'chaco'];
        %            ylim=.45;
    case {'china'}
        longlatbox=[75 120 15 60];
        filename=[filename '_china'];
        %            ylim=.42;%.37;%.32;%52
    case {'india'}
        longlatbox=[65 100 5 40];
        filename=[filename '_india'];
        %            ylim=.35%.32;
    case {'indonesia'}
        longlatbox=[80 155 -25 15];
        filename=[filename '_indonesia'];
        %            ylim=.27;%.32;
    case {'chinatropical'}
        longlatbox=[80 140 10 35];
        filename=[filename '_chinatropical'];
        %            ylim=.32;
    case {'mexico'}
        longlatbox=[-125 -80 10 35];
        filename=[filename '_mexico'];
    case {'southafrica'}
        longlatbox=[15 40 -40 -20];
        filename=[filename '_southafrica']; 
    case {'minnesota'}
        longlatbox=[-75 -65 40 50];
        filename=[filename '_minnesota'];
    case {'southeastasia'}
        longlatbox=[90 150 -15 +30];
        filename=[filename 'southeastasia'];
    case {'medit2north'}
        longlatbox=[0 96 35 72];
        filename=[filename 'medit2north'];
    otherwise
        load /ionedata/misc/gadm1_lev0
        for j=1:length(S)
            names{j}=lower(S(j).NAME_ENGLI);
            namesISO{j}=S(j).ISO;
        end
        ii=strmatch(lower(plotarea),names,'exact');
        jj=strmatch(lower(plotarea),lower(namesISO),'exact');
        
        if length(jj)==1
            kk=jj;
        elseif length(ii)==1
            kk=ii;
        else
            error(['Don''t recognize plotarea ' plotarea]);
        end
        
        filename=[filename S(kk).NAME_ENGLI];
        bb=S(kk).BoundingBox;
        longlatbox=[bb(1) bb(2) bb(3) bb(4)];
        
        
        
        
        %% attempt to fix
        longlatbox=nsg_unproject(longlatbox);
        
        
       
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
        case {'triangles','froufrou','panoply','pan'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'panoplytriangles',ThisValue); 
        case {'plotdatafile','savedata','datafile','makedatafile'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'makeplotdatafile',ThisValue);
        case {'hgsave','hgfile'}
            NSS=rmfield(NSS,ThisProperty);
            NSS=setfield(NSS,'figfilesave',ThisValue);
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
