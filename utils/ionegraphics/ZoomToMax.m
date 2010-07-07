function ZoomToMax(varargin);
% ZOOMTOMAX - Zoom graph to maximum value.
%
%  syntax:
% 
%   ZoomToMax('Initialize')
%   ZoomToMax('ZoomIn')
%   ZoomToMax('ZoomOut')

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('String','Zoom to max','Callback', ...
            'ZoomToMax(''ZoomIn'')','position',NextButtonCoords);
        uicontrol('String','Zoom Out','Callback', ...
            'ZoomToMax(''ZoomOut'');','position',NextButtonCoords);
        
    case 'ZoomIn'
        % find maximum, zoom in       
        
        UDS=get(gcbf,'UserData');
        ha=UDS.DataAxisHandle;
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
        

        
        if isvector(xx)==1
            [minval,RowIndex,ColumnIndex]=max2d(z);
            LongVal=xx(ColumnIndex);
            LatVal=yy(RowIndex);
        else
            ii=find(isnan(xx) | isnan(yy));
            z(ii)=max(max(z(ii)))+1;
            xx=imresize(xx,size(z));
            yy=imresize(yy,size(z));
            % assign maximal values here ... this
            %makes sure that we don't sneak by with a NaN
            % this is necessary because the mapping toolbox pads the x and y
            % matrices with NaNs
            [minval,RowIndex,ColumnIndex]=max2d(z);
            LongVal=xx(RowIndex,ColumnIndex);
            LatVal=yy(RowIndex,ColumnIndex);
        end
        
        %% need to find out how much user wants us to zoom by.  It's
        %% encoded in the userdatastructure in the figure window.
        if (UDS.MapToolboxFig==1)
            UDS=get(gcbf,'UserData');
            DeltaLong=.05;
            DeltaLat=.025;
        else
            DeltaLong=3.0;
            DeltaLat=1.5;
        end
        
        axis(UDS.DataAxisHandle,[LongVal-DeltaLong LongVal+DeltaLong LatVal-DeltaLat LatVal+DeltaLat]);
  
        
        [CountryNumber,CountryName]=GetCountry5min(LongVal,LatVal);
        
        disp(CountryName)
        
       
    case 'ZoomOut'
        
        try
            CanMap=CheckForMappingToolbox;
        catch
            disp(['problem with Mapping Toolbox check in ' mfilename]);
            CanMap=0;
        end
        
        UDS=get(gcbf,'UserData');
        ha=UDS.DataAxisHandle;
        
        axes(ha);
        if CanMap==0
            axis([-180 180 -90 90]);
        else
            axis 'auto xy'
        end
    otherwise
        error('syntax error in ZoomToMax.m')
        
end
end