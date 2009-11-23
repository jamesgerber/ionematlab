function PropagateLimits(varargin);
% PROPAGATELIMITS - propagate limits from this figure to all "IonEFigures"

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};

switch(InputFlag)
    case 'Initialize'
        uicontrol('String','Export Limits','Callback', ...
            'PropagateLimits(''Export'')','position',NextButtonCoords);	

 case 'Export'
  %%% get the limits of this axis  
  hax=get(gcbf,'CurrentAxes');
  Xlim=get(hax,'XLim');
  Ylim=get(hax,'YLim');
  
  
  hall=allchild(0); % all handles
  for j=1:length(hall)
    if isequal(get(hall(j),'Tag'),'IonEFigure');
      % we have an "IonEFigure". Resize.
      PropagateLimits('Import',hall(j),Xlim,Ylim);
    end
  end
  
 case 'Import';
  ThisFig =varargin{2};
  ThisXLim=varargin{3};
  ThisYLim=varargin{4};  
  figure(ThisFig) % it might be cleaner to search for the axes.
                  % Alternatively, search for the tags on the axes themselves.
  set(gca,'XLim',ThisXLim);
  set(gca,'YLim',ThisYLim);  
  
    otherwise
        error('syntax error in PropagateLimits.m');
        
end

