function varargout=IonESurf(Long,Lat,Data,Units,TitleStr);
% IonESurf - Make a surface plot consistent with IONE standards
%
% SYNTAX
%     IonESurf(Long,Lat,Data) will make a surface plot 
%
%     IonESurf(Long,Lat,Data,Units,TitleStr) will put 'Units','Title' on
%     the plot
%   
%     IonESurf(Data);  will assume global coverage of data and construct
%     Long, Lat
%
%     IonESurf(DS);  where DS is a matlab structure will look for fields
%     Long, Lat, Data, Title, Units
if nargin==0
  help(mfilename);
  return
end
    

Units='';


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




%if length(Long)<=2160
%    disp([' data is 10 min or coarser.  not downsampling.']);
    RedLong=Long;
    RedLat=Lat;
    RedData=Data;
%else
%    [RedLong,RedLat,RedData]=DownMap(Long,Lat,Data);
%end

hfig=figure;
pos=get(hfig,'Position');
pos=pos.*[1 1 1.5 .9];
set(hfig,'Position',pos);
set(hfig,'Tag','IonEFigure');

% Establish a UserDataStructure



if CanMap==0
  h=surface(RedLong,RedLat,double(RedData.'));
  UserDataStructure.WestWorldEdge=-180;
  UserDataStructure.EastWorldEdge=180;
  UserDataStructure.NorthWorldEdge=90;
  UserDataStructure.NorthWorldEdge=-90;
  UserDataStructure.ZoomLongDelta=(5);
  UserDataStructure.ZoomLatDelta=(2.5);  
else
  axesm('mercator')
  [lat2D,lon2D]=meshgrat(RedLat,RedLong);  
  h=surfm(lat2D,lon2D,double(RedData.'));
  UserDataStructure.WestWorldEdge=-pi;
  UserDataStructure.EastWorldEdge=pi;
  UserDataStructure.NorthWorldEdge=pi;
  UserDataStructure.NorthWorldEdge=-pi;
  UserDataStructure.ZoomLongDelta=(5*pi/180);
  UserDataStructure.ZoomLatDelta=(2.5*pi/180);  
end

set(hfig,'UserData',UserDataStructure);

set(gca,'Tag','IonEAxis')
shading flat
ht=title(TitleStr);
set(ht,'interpreter','none');
hcb=colorbar;
hy=get(hcb,'YLabel');
set(hy,'String',Units);
WorldSummary('Initialize');
ZoomToMax('Initialize');
ZoomToMin('Initialize');
MakeReducedDataSets('Initialize');
AddCoastCallback('Initialize');
ZoomToContinent('Initialize');
PropagateLimits('Initialize');
OutputFig('Initialize');


if exist('NoDataStructure');
    set(hfig,'UserData',NoDataStructure);
end


set(gcf,'Renderer','zbuffer')
zoom on
if nargout==1
    varargout{1}=h;
end

