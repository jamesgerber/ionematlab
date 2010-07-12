function IonEButtonDownFunctions(varargin);

if nargin==0
    help(mfilename);
    return
end

Hfig=gcbf;
InputFlag=varargin{1};
CallbackString=['Figure Zoom|Zoom To Point|Point Data'];

switch(InputFlag)
    case 'Initialize'
        position=NextButtonCoords;
        %%%[20 65 100 20]
        uicontrol('style','popupmenu','String',CallbackString,'Callback', ...
            'IonEButtonDownFunctions(''ChangeButtonBehaviorCallback'')',...
            'position',position);
        return
    case 'ChangeButtonBehaviorCallback'
        
        % case 'ChangeProjectionCallback'
        %Val will be the number corresponding to the string of the uicontrol.
        Val=get(gcbo,'Value');
        
        switch Val
            case 1
                zoom(Hfig,'on');
                
            case 2
                zoom(Hfig,'off');
                set(Hfig,'WindowButtonDownFcn',@ZoomToPointButtonDownCallback);
                
            case 3
                zoom(Hfig,'off');
                set(Hfig,'WindowButtonDownFcn',@PointSummaryButtonDownCallback);
                
            otherwise
                error(['syntax error in ' mfilename])
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PointSummaryButtonDownCallback   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PointSummaryButtonDownCallback(src,event) 
if strcmp(get(src,'SelectionType'),'normal')
    UDS=get(gcbf,'UserData');
    if (UDS.MapToolboxFig==1)
        pt=gcpmap;
        y=pt(1,1);
        x=pt(1,2);
        [a1 b1]=getRowCol(UDS.Lat,UDS.Long,y,x);
        z=UDS.Data(b1,a1);
        Scale=1;
    else
        cp=get(UDS.DataAxisHandle,'CurrentPoint');
        x=cp(1,1);
        y=cp(1,2);
        [a1 b1]=getRowCol(UDS.Lat,UDS.Long,y,x);
        z=UDS.Data(b1,a1);
        Scale=UDS.ScaleToDegrees;
    end
    CountryName=UDS.States(b1,2161-a1);
    
     %%% now set text in the console
     % first delete old text
     h=findobj('Tag','IonEConsoleText');
     delete(h);
     
     %now new text
     hc=UDS.ConsoleAxisHandle;
     axes(hc)
     set(hc,'xlim',[0 1]);
     set(hc,'ylim',[0 1]);
     if (length(CountryName{1})>=3)
        ht=text(0.02,.0,['Country = ' {StandardCountryNames(CountryName{1}(1:3),'sage3','sagecountry')}]);
        set(ht,'Tag','IonEConsoleText');
     end
     ht=text(0.02,.3,['SAGE = ' CountryName]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.6,['Value = ' num2str(z)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.8,['Lat = ' num2str(y)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,1.0,['Lon = ' num2str(x)]);
     set(ht,'Tag','IonEConsoleText');  
     axes(UDS.DataAxisHandle);  %make data axis handle current
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ZoomToPointButtonDownCallback   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ZoomToPointButtonDownCallback(src,event)

if strcmp(get(src,'SelectionType'),'normal')
    UDS=get(gcbf,'UserData');
    cp=get(UDS.DataAxisHandle,'CurrentPoint');
    x1=cp(1,1);
    y1=cp(1,2);
    if (UDS.MapToolboxFig==1)
        DeltaLong=.05;
        DeltaLat=.025;
        pt=gcpmap;
        y=pt(1,1);
        x=pt(1,2);
        [a1 b1]=getRowCol(UDS.Lat,UDS.Long,y,x);
        z=UDS.Data(b1,a1);
        Scale=1;
    else
        DeltaLong=3.0;
        DeltaLat=1.5;
        x=x1;
        y=y1;
        [a1 b1]=getRowCol(UDS.Lat,UDS.Long,y,x);
        z=UDS.Data(b1,a1);
        Scale=UDS.ScaleToDegrees;
    end
    CountryName=UDS.States(b1,2161-a1);
     %%% now set text in the console
     % first delete old text
     h=findobj('Tag','IonEConsoleText');
     delete(h);
     
     %now new text
     hc=UDS.ConsoleAxisHandle;
     axes(hc)
     if (length(CountryName{1})>=3)
        ht=text(0.02,.0,['Country = ' {StandardCountryNames(CountryName{1}(1:3),'sage3','sagecountry')}]);
        set(ht,'Tag','IonEConsoleText');
     end
     ht=text(0.02,.3,['SAGE = ' CountryName]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.6,['Value = ' num2str(z)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.8,['Lat = ' num2str(y)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,1.0,['Lon = ' num2str(x)]);
     set(ht,'Tag','IonEConsoleText');  
     
     LongVal=x1;
     LatVal=y1;
     % now want to zoom axes ...
     
     axis(UDS.DataAxisHandle,[LongVal-DeltaLong LongVal+DeltaLong LatVal-DeltaLat LatVal+DeltaLat]);

     % now rescale caxis
     
    % if isvector(xx)
     %else
      axes(UDS.DataAxisHandle); %make data axis handle current
end

function [a b]=getRowCol(LT,LN,lat,lon)
a=1;
while ((LT(a,1)<lat)&&(a<2160))
    a=a+1;
end
b=1;
while ((LN(b,1)<lon)&&(b<4320))
    b=b+1;
end