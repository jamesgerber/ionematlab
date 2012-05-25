function DBReallyfattenPlot(hfig)

if ~exist('hfig')
   hfig=gcf;
end

figure(hfig)

%set(gca,'fontweight','bold')

h=get(hfig,'children');

for j=1:length(h)
   if ~strcmp(get(h(j),'tag'),'legend') & ~strcmp(get(h(j),'type'),'uicontrol')
      set(h(j),'fontweight','bold','FontSize',15)
     try
         set(get(h(j),'children'),'linewidth',2)
     catch
         disp(['problem in fattenplot'])
     end
     set(h(j),'linewidth',2)
      set(get(h(j),'ylabel'),'fontweight','bold','FontSize',15)
      set(get(h(j),'title'),'fontweight','bold','FontSize',15)
      set(get(h(j),'xlabel'),'fontweight','bold','FontSize',15)
  else
      %its a legend, or a uicontrol ignore
     set(h(j),'fontweight','bold')
  end
end

%now section for ubertitles
h=findobj(hfig,'tag','UBERTITLE')
set(h,'FontWeight','bold','FontSize',15)