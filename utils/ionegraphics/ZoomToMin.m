function ZoomToMin(varargin);
% ZOOMTOMIN - Zoom graph to minimum value.

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('String','Zoom to min','Callback', ...
            'ZoomToMin(''ZoomIn'')','position',[180 10 80 20]);
      %  uicontrol('String','Zoom Out','Callback', ...
      %      'ZoomToMin(''ZoomOut'');','position',[260 10 60 20]);
        
    case 'ZoomIn'
        % find minimum, zoom in       
        
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
        
        ii=find(~isnan(z) & z~=0);
                
        [minval,RowIndex,ColumnIndex]=max2d(-z);
        
        LongVal=xx(ColumnIndex);
        LatVal=yy(RowIndex);
        
        axis([LongVal-5 LongVal+5 LatVal-5 LatVal+5]);
        
        [CountryNumber,CountryName]=GetCountry5min(LongVal,LatVal);    ;
        
        disp(CountryName)
        
        
    case 'ZoomOut'
        ha=get(gcbf,'CurrentAxes');
        
        axes(ha);
        axis([-180 180 -90 90]);
    otherwise
        error('syntax error in ZoomToMin.m')
        
end
end
