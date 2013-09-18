function Zerozlim(h,Ymax);
% ZEROYLIM - sets the z=0 axis to zero.
% SYNTAX:
%
%   Zeroylim(AxisHandle)  - sets the lower z limit to 0 on axis whos handle is
%                           AxisHandle 
%
%   Zeroylim              - sets the lower z limit to 0 on current axis  (via
%                           gca command)
%   
%   Zeroylim(Zmax)        - sets the lower z limit to 0 on current axis  (via
%                           gca command), upper zlimit to Zmax
%   
%   
%   ZeroYlim(Zmin,Zmax)   - sets the lower z limit to Zmin on current axis  (via
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

xv=get(h,'zylim');
set(h,'zlim',xv.*[0 1]);

