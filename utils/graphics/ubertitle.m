function varargout=ubertitle(str,Hfig,varargin);
% UBERTITLE - place a title above subplots
%
%  Syntax
%
%   ht=ubertitle('foo')  will place the text foo at the center, top of 
%                        the current figure.  Handle to text returned in ht.
%
%   ubertitle('foo',Hfig) places the text in figure Hfig
%
%   ubertitle('foo',gcf) is the same as ubertitle('foo')
%
%   ubertitle('foo',gcf,'PropertyName1',PropertyValue1, ...) will assign 
%                        'PropertyName1',PropertyValue1 ... to the text.
%
%   ubertitle('foo',gcf,'interp','none')  will turn off the interpreter
%
%   Note that ubertitle will delete previous ubertitles
%
%
% example
%
%  ubertitle('foo_{\pi}',gcf,'fontsize',15,'interp','none')
%  pause (3)
%   ubertitle('foo_{\pi}',gcf,'fontsize',15,'interp','tex')

% James Gerber
% Ocean Power Technologies

hax=gca;
if ~exist('Hfig')
    Hfig=gcf;
end

figure(Hfig);
%first kill old ubertitles in this figure
killme=findobj(gcf,'tag','UBERTITLE');
delete(killme)

axes('visible','off','position',[0 .96 1 .04]);

ht=text(.5,.3,str);
set(ht,'horiz','center','tag','UBERTITLE','interp','none');
%set(ht,'horiz','center','tag','UBERTITLE','interpreter','tex');


if length(varargin)>1
    set(ht,'horiz','center','tag','UBERTITLE',varargin{:});
end

if nargout==1;
    varargout{1}=ht;
end

%axes(hax)

%there is a bug in matlab ver 7, which causes the previous line to delete
%legends in the current axes (which it should, according to the
%documentation, just make the axis current.)   The following lines make a
%trivial change to the axes, which somehow makes them current without
%erasing legends.
vis=get(hax,'visibl');
set(hax,'visible',vis)
axes(hax)