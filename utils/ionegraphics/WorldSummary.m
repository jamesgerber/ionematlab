function WorldSummary(varargin);
% WorldSummary - Summary of data
%
%  WorldSummary('Initialize') and put up a uicontrol which when pressed
%  will make a summary plot.

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('String','Summary','Callback', ...
            'WorldSummary(''MakeSummary'')','position',[20 10 60 20]);
    case 'MakeSummary'
        
        ha=get(gcbf,'CurrentAxes');
        Xlim=get(ha,'XLim');
        Ylim=get(ha,'YLim');
        hc=get(ha,'Child');
        xx=get(hc,'XData');
        yy=get(hc,'YData');
        z=get(hc,'ZData');
        ii=find(~isnan(z) & z~=0);
        
        
        [maxval,RowIndex,ColumnIndex]=max2d(z)
        
        LongVal=xx(ColumnIndex);
        LatVal=yy(RowIndex);
        
        
        [CountryNumber,CountryName]=GetCountry5min(LongVal,LatVal);
        
        
        figure
        h1=subplot(321);
        
        % figure out  FigureTitle
        if isequal(lower(get(gcbf,'IntegerHandle')),'on');
            FigureName=['Figure ' num2str(gcbf)];
            FigureTitle=get(get(ha,'Title'),'String');
        else
            FigureName='Figure ';
            FigureTitle=get(get(ha,'Title'),'String');
        end
        x=.02;
        y=.95;
        dely=-.15;    set(h1,'Visible','Off')
        text(x,y,['Summary of ' FigureName]);y=y+dely;
        text(x,y,['Title: ' FigureTitle]);y=y+dely;
        text(x,y,['Mean Value = ' num2str(mean(z(ii)))]);y=y+dely;
        text(x,y,['Min Value = ' num2str(min(z(ii)))]);y=y+dely;
        text(x,y,['Max Value = ' num2str(max(z(ii)))]);y=y+dely;
        text(x,y,['Max Long = ' num2str(LongVal)]);y=y+dely;
        text(x,y,['Max Lat = ' num2str(LatVal)]);y=y+dely;
        text(x,y,['Location Max  = ' sprintf('%s',CountryName{1})]);y=y+dely;
        
        subplot(323)
        hist(z(ii),40);
        title(['Data histogram'])
        
        
        subplot(122);
        % keyboard
        
        deg=-87.5:5:87.5;
        for m=1:length(deg);
            ii=find( yy > deg(m)-2.5 & yy <= deg(m)+2.5);
            zonestrip=z(ii,:);
            jj=find(~isnan(zonestrip) & zonestrip~=0);
            if isempty(jj)
                avgval(m)=0;
                maxval(m)=0;
            else
                avgval(m)=mean(zonestrip(jj));
                maxval(m)=max(zonestrip(jj));
            end
        end
        plot(avgval,deg,maxval,deg)
        legend('average','maximum')
        
        
        
        h3=subplot(325);
        hf=get(gcbf,'children');
        for j=1:length(hf);
            if isequal(get(hf(j),'Tag'),'Colorbar')
                hcb=hf(j);
                hyl=get(hcb,'Ylabel');
                Units=get(hyl,'String');
            else
                Units='';
            end
            
            
        end
        x=.1;
        y=.95;
        dely=-.15;
        text(x,y,['Units: ' Units]);y=y+dely;
        set(h3,'Visible','Off')
        
    otherwise
        error('syntax error.  case statement in WorldSummary')
        
end
