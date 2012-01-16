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
  Xlim=get(hax,'XLim')
  Ylim=get(hax,'YLim')
  
  
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
        fud=get(ThisFig,'userdata');
        
        y0=ThisYLim(2)
        dely=diff(ThisYLim);
        x0=mean(ThisXLim);
        if isfield(fud,'titlehandle')
            delete(fud.titlehandle);
        end
        ht=text(x0,y0+0.05,fud.titlestring);
        set(ht,'FontSize',14)
        set(ht,'HorizontalAlignment','center');

        set(ht,'FontWeight','Bold');
        set(ht,'tag','NSGTitleTag');
        fud.titlehandle=ht;
        set(ThisFig,'userdata',fud);
         UserInterpPreference=callpersonalpreferences('texinterpreter');
            
            set(ht,'interp',UserInterpPreference);
    otherwise
        error('syntax error in PropagateLimits.m');
        
end

