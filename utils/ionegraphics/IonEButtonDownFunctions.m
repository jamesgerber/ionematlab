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
    cp=get(UDS.DataAxisHandle,'CurrentPoint');
    Scale=UDS.ScaleToDegrees;
    x=cp(1,1);
    y=cp(1,2);
    [CountryNumbers,CountryNames]=...
        GetCountry_halfdegree(x*Scale,y*Scale);
    CountryName=CountryNames{1};
    ii=find(CountryName==',');
    if ~isempty(ii)
        CountryName=CountryName(1:(ii(1)-1));
    end

     [xx,yy,z]=GetSurfaceDataFromAxes;
     
     %% section to find this value.  tricky if xx,yy are mappings.  use
     %% some ugly code...
     if ~isvector(xx)
         xxvect=xx(1:numel(xx));
         yyvect=yy(1:numel(xx));
         zvect=z(1:numel(z));
         [dum,ii]=min( (xxvect-x).^2+(yyvect-y).^2);
         zvalue=z(ii);
     else
         [dum,ix]=min((xx-x).^2);
         [dum,iy]=min((yy-y).^2);
         zvalue=z(iy,ix);
     end
     %%% now set text in the console
     % first delete old text
     h=findobj('Tag','IonEConsoleText');
     delete(h);
     
     %now new text
     hc=UDS.ConsoleAxisHandle;
     axes(hc)
     set(hc,'xlim',[0 1]);
     set(hc,'ylim',[0 1]);
     ht=text(0.02,.2,['Country=' CountryName]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.4,['Value = ' num2str(zvalue)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.6,['Lat = ' num2str(y)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.8,['Lon = ' num2str(x)]);
     set(ht,'Tag','IonEConsoleText');     
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ZoomToPointButtonDownCallback   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ZoomToPointButtonDownCallback(src,event)

if strcmp(get(src,'SelectionType'),'normal')
    
    UDS=get(gcbf,'UserData');
    cp=get(UDS.DataAxisHandle,'CurrentPoint');
    Scale=UDS.ScaleToDegrees;
    x=cp(1,1);
    y=cp(1,2);
    [CountryNumbers,CountryNames]=...
        GetCountry_halfdegree(x*Scale,y*Scale);
    CountryName=CountryNames{1};
    ii=find(CountryName==',');
    if ~isempty(ii)
        CountryName=CountryName(1:(ii(1)-1));
    end

     [xx,yy,z]=GetSurfaceDataFromAxes;
     
     %% section to find this value.  tricky if xx,yy are mappings.  use
     %% some ugly code...
     if ~isvector(xx)
         xxvect=xx(1:numel(xx));
         yyvect=yy(1:numel(xx));
         zvect=z(1:numel(z));
         [dum,ii]=min( (xxvect-x).^2+(yyvect-y).^2);
         zvalue=z(ii);
     else
         [dum,ix]=min((xx-x).^2);
         [dum,iy]=min((yy-y).^2);
         zvalue=z(iy,ix);
     end
     %%% now set text in the console
     % first delete old text
     h=findobj('Tag','IonEConsoleText');
     delete(h);
     
     %now new text
     hc=UDS.ConsoleAxisHandle;
     axes(hc)
     ht=text(0.02,.2,['Country=' CountryName]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.4,['Value = ' num2str(zvalue)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.6,['Lat = ' num2str(y)]);
     set(ht,'Tag','IonEConsoleText');
     ht=text(0.02,.8,['Lon = ' num2str(x)]);
     set(ht,'Tag','IonEConsoleText');  
     
     LongVal=x;
     LatVal=y;
     % now want to zoom axes ...
     try
         DeltaLong=UDS.ZoomLongDelta;
         DeltaLat=UDS.ZoomLatDelta;
     catch
         DeltaLong=2.5;
         DeltaLat=2.5;
     end
     
     axis(UDS.DataAxisHandle,[LongVal-DeltaLong LongVal+DeltaLong LatVal-DeltaLat LatVal+DeltaLat]);

     % now rescale caxis
     
    % if isvector(xx)
         ix=find(xx>LongVal-DeltaLong & xx< LongVal+DeltaLong);
         iy=find(yy>LatVal-DeltaLat & yy <LatVal+DeltaLat);
     
         lowerval=min(min(z(iy,ix)));
         upperval=max(max(z(iy,ix)));
     %else
      caxis([UDS.DataAxisHandle],[lowerval upperval]);   
end
