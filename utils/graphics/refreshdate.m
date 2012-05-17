function refreshdate(Hfig)
%  refreshdate - refresh date when 'datetick' was used for x label
%
%  % SYNTAX
%         refreshdate  will refresh the xlabel on the current axis
%         refreshdate(Hfig) will refresh the xlabel on figure Hfig
%
%   This function is most useful, however, when put into a UI callback and 
% used in conjunction with zooming.
%
%  Simply execute
%  uicontrol('callback','refreshdate','string','Refresh')

tmp=version;
if str2num(tmp(1)) > 6
    OLD=0;
else
    OLD=1;
end


if nargin==0
    Hfig=gcbf;
    if isempty(Hfig)
        disp(['gcbf returned empty.  executing gcf command']);
        disp([' uicontrol(''callback'',''refreshdate'',''string'',''Refresh'') ']);
        Hfig=gcf;
    end
end

h=allchild(Hfig);

for j=1:length(h);
    if isequal(get(h(j),'type'),'axes')  & ~isequal(get(h(j),'tag'),'legend')
        if OLD
            axes(h(j))
            datetick('keeplimits');
        else
            datetick(h(j),'keeplimits');
        end
        pos=get(h(j),'Position');
        if pos(2)<.2
            %close to the bottom ... so put on a date.
                xlim=get(h(j),'XLim');
            if OLD
                axes(h(j))
                xlabel(['Interval from  ' datestr(xlim(1),0) '  to  ' datestr(xlim(2),0)]);
            else
                xlabel(h(j),['Interval from  ' datestr(xlim(1),0) '  to  ' datestr(xlim(2),0)]);
            end
        end
    end
end

legend
