function mtZoomToContinent(varargin);
% MTZOOMTOCONTINENT -€“ zoomtocontinent modified to work with mtnicesurfgeneral

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('style','popupmenu','String','pick a continent|North America|Europe|Asia|Africa|South America|Australia|World','Callback', ...
            'ZoomToContinent(''ZoomIn'')','position',NextButtonCoords);	

    case 'ZoomIn'
 
        % get scaling factor
        try
            CanMap=CheckForMappingToolbox;
        catch
            disp(['problem with Mapping Toolbox check in ' mfilename]);
            CanMap=0;
        end
         
        % make user choose continent, zoom in       
        Val=get(gcbo,'Value');  %Val will be the number
                                %corresponding to the string of the uicontrol
%      switch Val
%       
%       case 1 %User chickened out
%        
%       case 2  %North America
%        alims=[-130 -70 10 65];
%       case 3 %Europe
%        alims=[-20 45 35 75];
%       case 4 % Asia
%        alims=[20 140 5 70];       
%       case 5 % Africa
%        alims=[-20 50 -35 35];
%       case 6 %South America
%        alims=[-110 -30 -60 25];
%       case 7 %Australia
%        alims=[90 180 -50 20];
%              case 8 %Australia
%        alims=[-180 180 -90 90];
%      end

     switch Val
      
      case 1 %User chickened out
       
      case 2  %North America
       alims=[-175 -08 05 90];
      case 3 %Europe
       alims=[-33 50 30 75];
      case 4 % Asia
       alims=[20 180 0 85];       
      case 5 % Africa
       alims=[-20 55 -40 40];
      case 6 %South America
       alims=[-90 -30 -60 17];
      case 7 %Australia
       alims=[90 180 -50 20];
             case 8 %World
       alims=[-180 180 -90 90];
     end
     


     UD=get(gcbf,'UserData');
     oldbox=UD.LongLatBox;
     UD.Data=matrixoffset(UD.Data,round(((mean(oldbox(1:2)))/360)*size(Data,1)),round(((mean(oldbox(3:4)))/180)*size(Data,2)));
     %UD.Data=matrixoffset(Data,-round(((-mean(oldbox(1:2)))/360)*size(Data,1)),round(((-mean(oldbox(3:4)))/180)*size(Data,2)));
     if CanMap==1
         NumPointsPerDegree=12*numel(UD.Lat)/2160;
   %     NumPointsPerDegree=1/(RedLat(2)-RedLat(1));
         R=[NumPointsPerDegree,90,-180];
         meshm(double(UD.Data),R,[50 100],-1);
         setm(UD.DataAxisHandle,'maplonlimit',[alims(1) alims(2)]);
         setm(UD.DataAxisHandle,'maplatlimit',[alims(3) alims(4)])
     else
         axis(UD.DataAxisHandle,alims);
     end
     set(gcbf,'UserData',UD);
     
	
	
    otherwise
        error('syntax error in ZoomToContinent.m')
        
end

