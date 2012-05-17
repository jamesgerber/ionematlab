function zeroylim(h,Ymax);
% ZEROyLIM - sets the y=0 axis to zero.
% SYNTAX:
%
%   zeroylim(AxisHandle)  - sets the lower y limit to 0 on axis whos handle is
%                           AxisHandle 
%
%   zeroylim              - sets the lower y limit to 0 on current axis  (via
%                           gca command)
%   
%   zeroylim(Ymax)        - sets the lower y limit to 0 on current axis  (via
%                           gca command), upper ylimit to Ymax
%   
%   
%   zeroylim(Ymin,Ymax)   - sets the lower y limit to Ymin on current axis  (via
%                           gca command), upper ylimit to Ymax
%   

% 
%   James Gerber
%   Ocean Power Technologies

if nargin==0
   h=gca;
else
    if nargin==2
        set(gca,'Ylim',[h Ymax]);
        return
    end
    if ~ishandle(h) %~strcmp(get(h,'type'),'axes')
        % warning('this handle is not an axis')
        %disp('using gca')
        set(gca,'Ylim',[0 h]);
        return
    end
end

xv=get(h,'Ylim');
set(h,'Ylim',xv.*[0 1]);

