function zerozlim(h,Ymax);
% ZEROzLIM - sets the z=0 axis to zero.
% SYNTAX:
%
%   zerozlim(AxisHandle)  - sets the lower z limit to 0 on axis whos handle is
%                           AxisHandle 
%
%   ZeroZlim              - sets the lower z limit to 0 on current axis  (via
%                           gca command)
%   
%   ZeroZlim(Zmax)        - sets the lower z limit to 0 on current axis  (via
%                           gca command), upper zlimit to Zmax
%   
%   
%   zeroylim(Zmin,Zmax)   - sets the lower z limit to Zmin on current axis  (via
%                           gca command), upper zlimit to Zmax
%   

% 
%   James Gerber
%   Ocean Power Technologies

if nargin==0
   h=gca;
else
    if nargin==2
        set(gca,'zlim',[h Ymax]);
        return
    end
    if ~ishandle(h) %~strcmp(get(h,'type'),'axes')
        % warning('this handle is not an axis')
        %disp('using gca')
        set(gca,'zlim',[0 h]);
        return
    end
end

xv=get(h,'zlim');
set(h,'zlim',xv.*[0 1]);

