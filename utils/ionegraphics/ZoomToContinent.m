function ZoomToContinent(varargin);
% ZOOMTOMAX - Zoom graph to maximum value.

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('style','popupmenu','String','pick a continent|North America|Europe|Asia|Africa|South America|Australia','Callback', ...
            'ZoomToContinent(''ZoomIn'')','position',[515 10 100 20]);	

    case 'ZoomIn'
 
        % get scaling factor
        try
            CanMap=CheckForMappingToolbox;
        catch
            disp(['problem with Mapping Toolbox check in ' mfilename]);
            CanMap=0;
        end

        if CanMap==0
            Scale=[1 1 1 1];
        else
            Scale=[pi/180 pi/180 pi/180 pi/180];
        end
          
        % make user choose continent, zoom in       
        Val=get(gcbo,'Value');  %Val will be the number
                                %corresponding to the string of the uicontrol
     switch Val
      
      case 1 %User chickened out
       
      case 2  %North America
       axis([-130 -70 10 65].*Scale)
      case 3 %Europe
       axis([-20 45 35 75].*Scale)
      case 4 % Asia
       axis([20 140 5 70].*Scale)       
      case 5 % Africa
       axis([-20 50 -35 35].*Scale)
      case 6 %South America
       axis([-110 -30 -60 25].*Scale)
      case 7 %Australia
       axis([90 180 -50 20].*Scale)
     end
     
	
	
    otherwise
        error('syntax error in ZoomToContinent.m')
        
end

