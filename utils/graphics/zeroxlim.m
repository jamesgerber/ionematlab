function zeroxlim(h,Xmax);
% ZEROxLIM - sets the x=0 axis to zero.
% SYNTAX:
%
%   zeroxlim(AxisHandle)  - sets the lower x limit to 0 on axis whos handle is
%                           AxisHandle 
%
%   zeroxlim              - sets the lower x limit to 0 on current axis  (via
%                           gca command)
%   
%   zeroxlim(Xmax)        - sets the lower x limit to 0 on current axis  (via
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
        return
    end
    if ~ishandle(h) %~strcmp(get(h,'type'),'axes')
        % warning('this handle is not an axis')
        %disp('using gca')
        set(gca,'Xlim',[0 h]);
        return
    end
end 
xv=get(h,'Xlim');
set(h,'Xlim',xv.*[0 1]);
