function planetview(long,lat,Data);
% planetview - put up data on a rotation globe
%
% Syntax
%
%   planetview(long,lat,Data);



if nargin==1
    % first argin is Data
    Data=long;
    [long,lat]=inferlonglat(Data);
end





phi=lat*pi/180;
theta=long*pi/180;

[theta2D,phi2D]=meshgrid(theta,phi);

Data(find(Data>1e10))=NaN;

% now set things up for surface ...
R=1;
X=R*cos(theta2D).*cos(phi2D);
Y=R*sin(theta2D).*cos(phi2D);
Z=R*sin(phi2D);

figure;surface(X,Y,Z,double(Data.'))
colorbar
hold on
Z=double(Z);
surface(X*.999,Y*.999,Z*.999,Z*0-1);

shading flat
axis vis3d
axis off
for j=1:2:360;
view(-j,0)
pause(.01)
end


