function varargout=semiflatfig(hfigin)
% SEMIFLATFIG - make a flattish figure
%
%    Syntax - 
%             flatfig  will open a flat figure window
%
%             Hfig=Flatfig;   will return the fig. hanlde
%
%             Flatfig(Hfig); will flatten Hfig

if nargin==0
    hfig=figure;
else
    hfig=hfigin;
end
%now shrink the size of the figure window
pos=get(hfig,'position');

dely=pos(4);

newdely=floor(dely*.8);

newpos=[pos(1) pos(2)+dely-newdely pos(3) newdely];

set(hfig,'position',newpos);

hax=gca;

pos=get(hax,'position');
dely=pos(4);

newdely=(dely*.8);

newpos=[pos(1) pos(2)+(dely-newdely)/2 pos(3) newdely];

set(hax,'position',newpos);

if nargout==1
    varargout{1}=hfig;
end
