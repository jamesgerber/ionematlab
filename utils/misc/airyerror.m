function E=airyerror(tep,t,y);
% AIRYERROR - determine mean square error of data and sine wave model  
%
%  Called by bestairyfit.m

T=tep(1);
eta=tep(2);
phase=tep(3);

if length(tep)==3
    xmean=0;
else
    xmean=tep(4);
end

ynum=xmean+eta*cos(t*2*pi/T+phase);

E=sum((y-ynum).^2)/sum(y.^2);
