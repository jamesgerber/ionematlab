function connect(Hfig)
% Connect - connect all axes in current figure for x-zooming
%
%

if nargin==0
   Hfig=gcf;
end

h=get(Hfig,'child');

%remove legends
s=get(h,'tag');
keep=~strcmp(s,'legend');
h=h(find(keep));
%remove non-axes
s=get(h,'type');
keep=~strcmp(s,'uicontrol');
h=h(find(keep));


verstr=version;
if str2num(verstr(1)) >=7
   linkaxes(h,'x');
else
   connectaxes('+x',h);
end

figure(Hfig)
zoom on


