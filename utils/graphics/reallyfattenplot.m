function ReallyfattenPlot(hfig)
% REALLYFATTENPLOT - make fonts bold and lines fatter
%
% SYNTAX
% ReallyfattenPlot(hfig) - fatten figure hfig
if ~exist('hfig')
    hfig=gcf;
end

figure(hfig)

%set(gca,'fontweight','bold')

h=get(hfig,'children');

for j=1:length(h)
    if ~strcmp(get(h(j),'tag'),'legend') && ~strcmp(get(h(j),'type'),'uicontrol')  &&~strcmp(get(h(j),'type'),'piechart')
        set(h(j),'fontweight','bold','FontSize',15)
        try
            set(get(h(j),'children'),'linewidth',4)
        catch
            disp(['problem in fattenplot'])
        end
        set(h(j),'linewidth',3)
        set(get(h(j),'ylabel'),'fontweight','bold','FontSize',15)
        set(get(h(j),'zlabel'),'fontweight','bold','FontSize',15)
        set(get(h(j),'title'),'fontweight','bold','FontSize',15)
        set(get(h(j),'xlabel'),'fontweight','bold','FontSize',15)
    elseif strcmp(get(h(j),'type'),'piechart')

        % ok ... piechart ... 2023b stuff ... ignore.

    else
        %its a legend, or a uicontrol ignore
        set(h(j),'fontweight','bold')
    end
end

%now section for ubertitles
h=findobj(hfig,'tag','UBERTITLE')
set(h,'FontWeight','bold','FontSize',15)
