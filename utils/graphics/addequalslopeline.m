function hline=addequalslopeline(hax)
% addequalslopeline - add a line of unit slope to an existing plot
%
%  Syntax
%     ADDEQUALSLOPELINE  adds a line of unit slope, extending axes as
%     needed.
%
%     ADDEQUALSLOPELINE(hax)

if nargin==0
    hax=gca;
end


y=get(gca,'YLim');
x=get(gca,'XLim');

ll=min(y(1),x(1));
ul=max(y(2),x(2));
hold on
hline=plot([ll ul],[ll ul],'k--');