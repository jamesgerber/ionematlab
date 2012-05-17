function ionebuttondownfunctions(varargin);

if nargin==0
    help(mfilename);
    return
end

Hfig=gcbf;
InputFlag=varargin{1};
CallbackString=['Figure Zoom|Zoom To Point|Point Data'];

switch(InputFlag)
    case 'Initialize'
        position=nextbuttoncoords;
        %%%[20 65 100 20]
        uicontrol('style','popupmenu','String',CallbackString,'Callback', ...
            'ionebuttondownfunctions(''ChangeButtonBehaviorCallback'')',...
            'position',position);
        return
    case 'ChangeButtonBehaviorCallback'
        
        % case 'changeprojectionCallback'
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
    cp=gcpmap;
    x=cp(1,1);
    y=cp(1,2);
    [CountryNumbers,CountryNames]=...
        getcountry_halfdegree(y,x);
    CountryName=CountryNames{1};
    ii=find(CountryName==',');
    if ~isempty(ii)
        CountryName=CountryName(1:(ii(1)-1));
    end

     [xx,yy,z]=getsurfacedatafromaxes;
     
     %% section to find this value.  tricky if xx,yy are mappings.  use
     %% some ugly code...
     if size(z,1)==2160 & size(z,2)==4320
         [yy,xx]=inferlonglat(z);
         [dum,ix]=min((xx-x).^2);
         [dum,iy]=min((yy-y).^2);
         zvalue=z(iy,ix);
         disp(['ix=' int2str(ix)])
         disp(['iy=' int2str(iy)])
         disp(['vectorindex=' int2str(sub2ind(size(z),iy,ix))]);
     elseif ~isvector(xx)
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
     axes(UDS.DataAxisHandle);  %make data axis handle current
     try   
         evalin('base','pointdata;');
     catch
         assignin('base','pointdata',cell(0,4));
     end
     pdataold=evalin('base','pointdata;');
     pdatanew=cell(size(pdataold,1)+1,4);
     pdatanew(2:size(pdatanew,1),:)=pdataold;
     pdatanew(1,:)={zvalue, CountryName, y, x};
     assignin('base','pointdata',pdatanew);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ZoomToPointButtonDownCallback   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ZoomToPointButtonDownCallback(src,event)

if strcmp(get(src,'SelectionType'),'normal')
    
    UDS=get(gcbf,'UserData');
    cp1=get(UDS.DataAxisHandle,'CurrentPoint');
    x1=cp1(1,1);
    y1=cp1(1,2);
    cp=gcpmap;
    x=cp(1,1);
    y=cp(1,2);
    [CountryNumbers,CountryNames]=...
        getcountry_halfdegree(y,x);
    CountryName=CountryNames{1};
    ii=find(CountryName==',');
    if ~isempty(ii)
        CountryName=CountryName(1:(ii(1)-1));
    end

     [xx,yy,z]=getsurfacedatafromaxes;
     
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
     
     try   
         evalin('base','pointdata;');
     catch
         assignin('base','pointdata',cell(0,4));
     end
     pdataold=evalin('base','pointdata;');
     pdatanew=cell(size(pdataold,1)+1,4);
     pdatanew(2:size(pdatanew,1),:)=pdataold;
     pdatanew(1,:)={zvalue, CountryName, y, x};
     assignin('base','pointdata',pdatanew);
     
     LongVal=x1;
     LatVal=y1;
     % now want to zoom axes ...
     try
         DeltaLong=UDS.ZoomLongDelta;
         DeltaLat=UDS.ZoomLatDelta;
     catch
         DeltaLong=2.5;
         DeltaLat=2.5;
     end
     
     axis(UDS.DataAxisHandle,[LongVal-DeltaLong LongVal+DeltaLong LatVal-DeltaLat LatVal+DeltaLat]);

%      % now rescale caxis
%      
%     % if isvector(xx)
%          ix=find(xx>LongVal-DeltaLong & xx< LongVal+DeltaLong);
%          iy=find(yy>LatVal-DeltaLat & yy <LatVal+DeltaLat);
%      
%          lowerval=min(min(z(iy,ix)));
%          upperval=max(max(z(iy,ix)));
%      %else
%       caxis([UDS.DataAxisHandle],[lowerval upperval]);
      axes(UDS.DataAxisHandle); %make data axis handle current
end
