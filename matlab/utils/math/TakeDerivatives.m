function [vel, accel, uu]=TakeDerivatives(x,delt,skipPoints)
% TAKEDERIVATIVES  calculate first and second derivatives
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function finds the velocity and acceleration from the position and the timestep via the central 
% differences methodology.   The code is the result of quadratically fitting 7 points (three back and 
% three forward) with respect to the point of interest.  The fit then has the derivative taken to get the
% velocity and acceleration....
%                  y'=a0+a1t'+a2t^2'
%                    vel=a1+2*a2t'.
%                  accel=2*a2
% Then least squares is used to move between y' and y.  
% 
%      SYNTAX:  [vel, accel, uu]=TakeDerivatives(x,delt,skipPoints)
%      
%      only one vector, the position x, must be passed to the code.  the time step must also be passed.
%      another value must be passed as well, skipPoints, the default value for this=1 (no points will be skipped)
%      
%      the code returns the first(vel) and second (accel) derivative of the passed vector, found via this central 
%      differences methodology. the code will also identify all location where vel~=0, this is uu.
%
%
%      EXAMPLE:
%               x=rand(1,10)
%               [vel,accel,uu]=TakeDerivatives(x,.1,1)
%      
% Diana Bull                                                                                           04-12-06
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin==2
    skipPoints=1;
end


ii=length(x);

x=x(:);
vel=[];
accel=[];

for ii=4*skipPoints:skipPoints:length(x)-3*skipPoints;
    jj=ii-3*skipPoints:skipPoints:ii+3*skipPoints;
    tspace=-3:1:3;
    Velocity=(sum(x(jj).*(tspace(:)))./28)./(delt.*skipPoints);
    Acceleration=((sum(x(jj).*(tspace(:)).^2)-4*sum(x(jj)))./42)/((delt.*skipPoints).^2);
    
    vel(ii)=[Velocity];
    accel(ii)=[Acceleration];
end

vel=[vel, zeros(1,3*skipPoints)];
accel=[accel, zeros(1,3*skipPoints)];


[NonZero uu]=find(vel~=0);

