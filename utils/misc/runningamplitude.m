function [ampvector]=runningamplitude(t,y,T);
% RUNNINGAMPLITUDE  Finds local amplitude for a signal. 
%
% Output is a vector of amplitudes.


t=t-t(1);


%find zero crossings
y=y-mean(y);
ii=find(y==0);

if ~exist('T')
    T=20;
end


ii=length(find(t<T));

jvect=1:ii:length(t);
jvect(end)=length(t)

for j=1:length(jvect)-1;
    ii=jvect(j):jvect(j+1);
    ytemp=y(ii);
    ytemp=ytemp-mean(ytemp)   ;
    amp=mean(ytemp(findpeaks(ytemp,max(ytemp)*.7)));
    ampvector(ii)=amp;
end
