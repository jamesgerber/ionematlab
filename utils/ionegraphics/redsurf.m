function varargout=redsurf(Long,Lat,Data);
% REDSURF Surface plot for a reduced dataset
%
%
if nargin==0
  help(mfilename);
  return
end
    
titlestr=inputname(nargin);

if nargin==1
  % first argin is Data
  Data=Long;

  % need some matlab witchcraft to get Long and Lat
  Long=evalin('base','LongRed');
  Lat =evalin('base','LatRed');
end

h=IoneSurf(Long,Lat,double(Data),'','');

if nargout==1
    varargout{1}=h;
end
