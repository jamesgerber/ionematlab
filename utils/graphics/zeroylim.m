function [ymin,ymax]=Zeroylim(h,Ymax);
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
        set(gca,'ylim',[h Ymax]);
        ymin=h;
ymax=Ymax;
        return
    end
    if ~ishandle(h) %~strcmp(get(h,'type'),'axes')
        % warning('this handle is not an axis')
        %disp('using gca')
        set(gca,'ylim',[0 h]);
ymin=0;
ymax=h;
        return
    end
end

xv=get(h,'ylim');
set(h,'ylim',xv.*[0 1]);

ymin=0;
ymax=xv(2);

