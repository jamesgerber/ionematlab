function [xmin,xmax]=ZeroXlim(h,Xmax);
% ZEROxLIM - sets the x=0 axis to zero.
% SYNTAX:
%
%   ZeroXlim(AxisHandle)  - sets the lower x limit to 0 on axis whos handle is
%                           AxisHandle 
%
%   ZeroXlim              - sets the lower x limit to 0 on current axis  (via
%                           gca command)
%   
%   ZeroXlim(Xmax)        - sets the lower x limit to 0 on current axis  (via
%                           gca command), upper ylimit to Xmax
%   

% 
%   James Gerber
%   Ocean Power Technologies
if nargin==0
    h=gca;
else
    if nargin==2
        set(gca,'Xlim',[h Xmax]);
        xmin=h;
        xmax=Xmax;
        return
    end
    if ~ishandle(h) %~strcmp(get(h,'type'),'axes')
        % warning('this handle is not an axis')
        %disp('using gca')
        set(gca,'Xlim',[0 h]);
        xmin=0;
        xmax=h;
        return
    end
end 
xv=get(h,'Xlim');
set(h,'Xlim',xv.*[0 1]);
xmin=0;
xmax=xv(2);
