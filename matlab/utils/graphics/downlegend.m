function downlegend(hfig)
% DOWNLEGEND - Decrease font size of legends
%
% Syntax  downlegend(FigNo)  will decrease the fontsize of all legends in figure FigNo by 1
%
%         downlegend will act on the current figure
%
%
% See also:   fattenplot, reallyfattenplot, uplegend
%
% James Gerber
% Ocean Power Technologies
% March, 2005


if ~exist('hfig')
   hfig=gcf;
end

figure(hfig)

h=get(hfig,'children');
hleg=findobj(h,'tag','legend');

for j=1:length(hleg);
    FontSize=get(hleg(j),'fontsize');
    set(hleg(j),'fontsize',FontSize-1);
end
