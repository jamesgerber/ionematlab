function varargout=IonESurf(Long,Lat,Data,Units,TitleStr);
% IonESurf - Make a surface plot consistent with IONE standards
%
% SYNTAX
%     IONESURF(Long,Lat,Data) will make a surface plot
%
%     IONESURF(Long,Lat,Data,Units,TitleStr) will put 'Units','Title' on
%     the plot
%
%     IONESURF(Data);  will assume global coverage of data and construct
%     Long, Lat
%
%     IONESURF(DS);  where DS is a matlab structure will look for fields
%     Long, Lat, Data, Title, Units
%
%
%     IonESurf is the base-level plotting routine written to
%     standardize and facilitate plotting.   It has a few limitations, and
%     so some other plotting routines have been written which call
%     IonESurf.
%     * IoneSurf can be slow, so FASTSURF, DOWNSURF, and THINSURF reduce
%     the dataset before calling IoneSurf
%     * IonESurf will plot the data that is sent to it ... so "dummy"
%     values for oceans (e.g. -90000000000000) can mess up the color axis.
%     NiceSurf looks for values like that and removes them, and takes out
%     anything over the oceans
%     * IonESurf doesn't necessarily result in a figure which will plot
%     nicely.  NICESURFGENERAL facilitates plotting.
%
%     See Also NiceSurf NiceSurfGeneral FastSurf DownSurf ThinSurf
if nargin==0
    help(mfilename);
    return
end


if nargin<4
    Units='';
end

InputVariableName=inputname(nargin);  %Variable name from calling workspace.
if nargin<5
    TitleStr=InputVariableName;
end

CanMap=CheckForMappingToolbox;


if nargin==1
    % only one argument in.  Either user is simply passing in a big array and
    % expecting ThinSurf to infer the Lat and Long, or that one argument is a
    % structure that has the data in it.
    
    %  note that whichever option is true, the variable is called Long.
    %  Rename to make the code more readable.
    Data=Long;
    clear Long
    if isstruct(Data)
        % it's a structure.  Call a utility to unpack ...
        [Long,Lat,Data,Units,DefaultTitleStr,NoDataStructure]=ExtractDataFromStructure(Data);
        % now check to make sure that we got a title.  If we didn't use the
        % input variable name.
        if nargin < 5
            % User did not supply a title.  We need to find in.  Best is
            % whatever came from ExtractDataFromStructure, but make sure it
            % isn't empty first
            if ~isempty(DefaultTitleStr)
                TitleStr=DefaultTitleStr;
            else
                TitleStr=InputVariableName
            end
        else
            % Comment to make code readable:
            % We are here bec user did supply TitleStr.  Nothing to do.
        end
        
    else
        % it's a matrix.  Call a utility to figure out Long, Lat
        
        [Long,Lat]=InferLongLat(Data);
        TitleStr=InputVariableName;
        Units='';
    end
end

RedLong=Long;
RedLat=Lat;
RedData=Data;


%% invert data to conform with matlab standard

RedLat=RedLat(end:-1:1);
RedData=RedData(:,end:-1:1);

hfig=figure;

zoom(hfig,'on');
% calculate place to put figure
if hfig <30
    XStart=100+30*hfig;
    YStart=350-20*hfig;
else
    XStart=100;
    YStart=350;
end

pos=get(hfig,'position');
newpos=[XStart YStart pos(3)*1.5 pos(4)*(0.9)];
%set(hfig,'position',[XStart YStart 842  440]);
set(hfig,'position',newpos);
%mps=get(0,'MonitorPositions');

%pos=pos.*[1 1 1.5 .9];
%set(hfig,'Position',pos);
set(hfig,'Tag','IonEFigure');

% Establish a UserDataStructure


meshmflag=1;

if CanMap==0
    h=surface(RedLong,RedLat,double(RedData.')*0-1,double(RedData.'));
%    set(gca,'Position',[0.1800    0.1100    0.6750    0.8150],'EdgeColor','none');
     set(gca,'Position',[0.1800    0.1100    0.6750    0.8150]);
    UserDataStructure.DataAxisHandle=gca;
    
    UserDataStructure.WestWorldEdge=-180;
    UserDataStructure.EastWorldEdge=180;
    UserDataStructure.NorthWorldEdge=90;
    UserDataStructure.SouthWorldEdge=-90;
    UserDataStructure.ZoomLongDelta=(5);
    UserDataStructure.ZoomLatDelta=(2.5);
    UserDataStructure.ScaleToDegrees=1;
    UserDataStructure.MapToolboxFig=0;
    
    UserDataStructure.QuickVersion=0;
else
%    hm=axesm('robinson','Frame','Off')

% changes here are intended to make the Patch FaceVertexCData length
% warning go away.  Need to have the patch, but by default it is empty,
% leading to warning.  So, we put in a bunch of ones.  that seems to make
% the error go away, and doesn't seem to change the output.

    hm=axesm('robinson','Frame','On');

    hpatch=findobj(allchild(hm),'type','patch')
    sz=get(hpatch,'Vertices');
%    set(hpatch,'FaceVertexCData',repmat([1 1 1],400,1))
    set(hpatch,'FaceVertexCData',ones(size(sz)));
    if meshmflag==0
        [lat2D,lon2D]=meshgrat(RedLat,RedLong);
        h=surfm(lat2D,lon2D,double(RedData.'));
    else
      NumPointsPerDegree=12*numel(RedLat)/2160;
   %     NumPointsPerDegree=1/(RedLat(2)-RedLat(1));
        R=[NumPointsPerDegree,90,-180];
        h=meshm(double(RedData.'),R,[50 100],-1);
    end
    shading flat;
    
    
    % set(gca,'Position',[0.1800    0.1100    0.6750    0.8150]);
    UserDataStructure.DataAxisHandle=gca;
    UserDataStructure.MapHandle=hm;
    UserDataStructure.SurfHandle=h;
    UserDataStructure.WestWorldEdge=-pi;
    UserDataStructure.EastWorldEdge=pi;
    UserDataStructure.NorthWorldEdge=pi;
    UserDataStructure.SouthWorldEdge=-pi;
    UserDataStructure.ZoomLongDelta=(5*pi/180);
    UserDataStructure.ZoomLatDelta=(2.5*pi/180);
    UserDataStructure.ScaleToDegrees=180/pi;
    UserDataStructure.MapToolboxFig=1;
    UserDataStructure.QuickVersion=0;
end

UserDataStructure.Lat=RedLat;
UserDataStructure.Long=RedLong;
UserDataStructure.Data=RedData;
UserDataStructure.SurfaceHandle=h;
%axes(UserDataStructure.DataAxisHandle);
set(gca,'Tag','IonEAxis')
shading flat
ht=title(TitleStr);
set(ht,'interpreter','none');
hcb=colorbar('peer',UserDataStructure.DataAxisHandle,'SouthOutside');
hy=get(hcb,'XLabel');
set(hy,'String',Units);
set(hy,'FontWeight','Bold')
UserDataStructure.ColorbarStringHandle=hy;
UserDataStructure.ColorbarHandle=hcb;
UserDataStructure.titlestring=TitleStr;


% now make graphics
clear NextButtonCoords

WorldSummary('Initialize');
ZoomToMax('Initialize');
ZoomToMin('Initialize');
MakeReducedDataSets('Initialize');
AddCoastCallback('Initialize');
ZoomToContinent('Initialize');
PropagateLimits('Initialize');
OutputFig('Initialize');
IonEButtonDownFunctions('Initialize');
PropagateCaxis('Initialize');


%% Add Console
position=[0.0,0.0,1,.1];
ConsoleAxisHandle=axes('units','normalized','Position',position);
set(ConsoleAxisHandle,'units','normalized'); %this is the default
set(ConsoleAxisHandle,'visible','off');
UserDataStructure.ConsoleAxisHandle=ConsoleAxisHandle;
set(hfig,'UserData',UserDataStructure);

% make dataaxis current

vis=get(UserDataStructure.DataAxisHandle,'visible');
set(UserDataStructure.DataAxisHandle,'visible',vis);
axes(UserDataStructure.DataAxisHandle);

if CheckForMappingToolbox;
    ChangeProjection('Initialize');
end



%if exist('NoDataStructure');
%    set(hfig,'UserData',NoDataStructure);
%end


set(gcf,'Renderer','zbuffer')

if nargout==1
    varargout{1}=hfig;
end



end