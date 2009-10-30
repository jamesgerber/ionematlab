function handle=plotcomplex(t,z,t2,z2);
% PLOTCOMPLEX   plot a complex vector 
%
%  Syntax:
%
%   h=Plotcomplex(Z)
%
%   h=Plotcomplex(f,Z)
%
%   h=Plotcomplex(f,Z,style)
%
%   h=Plotcomplex(f,Z,f2,Z2);

if nargin==1
   z=t;
   t=1:length(z);
   strname=inputname(1)
else
      strname=inputname(2);
end
 
if nargin==3
    style=t2;
else
    style='-';
end



if nargin<4
    subplot(211)
    h(1)=plot(t,real(z),style);
    legend(['real(' strname ')']);
    grid on
    
    subplot(212)
    h(2)=plot(t,imag(z),style);
    grid on
    legend(['imag(' strname ')']);
    if nargout==2
        handle=h;
    end
    return
end


if nargin==4
      strname1=inputname(2);
      strname2=inputname(4);

    subplot(211)
    h(1:2)=plot(t,real(z),t2,real(z2),style);
    legend(['real(' strname1 ')'],['real(' strname2 ')']);
    grid on
    
    subplot(212)
    h(3:4)=plot(t,imag(z),t2,imag(z2),style);
    legend(['imag(' strname1 ')'],['imag(' strname2 ')']);
    grid on
    if nargout==2
        handle=h;
    end
    return
end