function untex
%UNTEX - set interpreter mode to none in current axis
%
% see also RETEX

% J Gerber
% Ocean Power Technologies, Inc.


hax=gca;
ht=get(hax,'Title');
set(ht,'interpreter','none')
ht=get(hax,'ylabel');
set(ht,'interpreter','none')
ht=get(hax,'xlabel');
set(ht,'interpreter','none')




   hfig=gcf;


figure(hfig)

h=get(hfig,'children');
hleg=findobj(h,'tag','legend');

for j=1:length(hleg);
    [legh,objh]=legend(hleg(j));
    for m=1:length(objh)
        if isequal( lower(get(objh(m),'type')),'text')
            set(objh(m),'interpreter','none');
        end
    end
end

% now look for ubertitles
try
    hh=get(gcf,'children');
    for j=1:length(hh)
        if isequal(lower(get(get(hh(j),'children'),'tag')),'ubertitle');
            set(get(hh(j),'children'),'interp','none');
        end
    end
catch
    disp(' problem in ubertitle section')
end
