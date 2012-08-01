function fattenPlotsmalllegend(hfig)
% FATTENPLOTSMALLLEGEND - fatten the plot but leave a small legend
%
% SYNTAX
% fattenPlotsmalllegend(hfig) - fatten figure hfig 
if ~exist('hfig')
   hfig=gcf;
end

figure(hfig)

%set(gca,'fontweight','bold')

h=get(hfig,'children');

for j=1:length(h)
   if ~strcmp(get(h(j),'tag'),'legend') & ~strcmp(get(h(j),'type'),'uicontrol')
      set(h(j),'fontweight','bold')
     try
         set(get(h(j),'children'),'linewidth',2)
     catch
         disp(['problem in fattenplot'])
     end
     set(h(j),'linewidth',1.5)
      set(get(h(j),'ylabel'),'fontweight','bold')
      set(get(h(j),'title'),'fontweight','bold')
      set(get(h(j),'xlabel'),'fontweight','bold')
      set(get(h(j),'zlabel'),'fontweight','bold')
  else
      %its a legend, or a uicontrol ignore
     set(h(j),'fontweight','normal','fontsize',6)
  end
end

%now go after patches for contours
try
    hh=get(h,'children');

    for j=1:length(hh);
        if strcmp(get(hh(j),'type'),'text')
            set(hh(j),'fontweight','bold')
            set(hh(j),'fontsize',15)
        end
        if strcmp(get(hh(j),'type'),'patch')
            set(hh(j),'linewidth',1.5)
        end
        
    end
end


%now section for ubertitles
h=findobj(hfig,'tag','UBERTITLE');
set(h,'FontWeight','bold')

