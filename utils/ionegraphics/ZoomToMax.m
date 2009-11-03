function ZoomToMax(varargin);
% ZOOMTOMAX - Zoom graph to maximum value.

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('String','Zoom to max','Callback', ...
            'ZoomToMax(''ZoomIn'')','position',[90 10 80 20]);
        uicontrol('String','Zoom Out','Callback', ...
            'ZoomToMax(''ZoomOut'');ZoomToMin(''ZoomOut'')','position',[270 10 60 20]);
        
    case 'ZoomIn'
        % find maximum, zoom in       
        
        ha=get(gcbf,'CurrentAxes');
        Xlim=get(ha,'XLim');
        Ylim=get(ha,'YLim');
        hc=get(ha,'Child');
        xx=get(hc,'XData');
        yy=get(hc,'YData');
        z=get(hc,'ZData');
        
        if iscell(z)
            z=z{end};
            xx=xx{end};
            yy=yy{end};
        end
        % little bit of code to handle z being all zeros (if mapping
        % toolbox was used)
        
        if length(unique(z))==1
            z=get(hc(end),'CData');
        end
        
        
        
            
        ii=find(isnan(xx) | isnan(yy));       
        z(ii)=min(min(z(ii)))-1;   
        % assign minimal values here ... this 
        % this is necessary because the mapping toolbox pads the x and y 
        % matrices with NaNs 
        
        
        [maxval,RowIndex,ColumnIndex]=max2d(z);
        
        LongVal=xx(ColumnIndex);
        LatVal=yy(RowIndex);

        
        %% need to find out how much user wants us to zoom by.  It's
        %% encoded in the userdatastructure in the figure window.
        try
            UDS=get(gcbf,'UserData');
            DeltaLong=UDS.ZoomLongDelta;
            DeltaLat=UDS.ZoomLatDelta;
        catch
            DeltaLong=2.5;
            DeltaLat=2.5;
        end
        
        axis([LongVal-DeltaLong LongVal+DeltaLong LatVal-DeltaLat LatVal+DeltaLat]);
        
        [CountryNumber,CountryName]=GetCountry5min(LongVal,LatVal)    ;
        
        disp(CountryName)
        
        
    case 'ZoomOut'
        ha=get(gcbf,'CurrentAxes');
        
        axes(ha);
        axis([-180 180 -90 90]);
    otherwise
        error('syntax error in ZoomToMax.m')
        
end
end
