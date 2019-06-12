function h=addyline(xval,linesty);
% addyline add a line parallel to y-axis on current figure

ylims=get(gca,'YLim')

holdstate=ishold;

hold on
h=plot([xval xval],ylims,linesty);

if holdstate==0
    hold off
end

    