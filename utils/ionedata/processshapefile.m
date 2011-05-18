function output=processshapefile(S,field,seek,xres,yres)
output=zeros(xres,yres);
        for i=1:xres
            X(xres,1:yres)=xres;
        end
        for i=1:yres
            Y(1:xres,yres)=yres;
        end
h=waitbar(0,'Shh...');
for i=1:length(S)
    if ((eval(['S(', num2str(i), ').', field]))==seek)
        polyx=(S(i).X+9000000)*xres/18000000;
        polyy=(S(i).Y+18000000)*yres/36000000;
        output=output|inpolygon(X,Y,polyx,polyy);
        waitbar(i/length(S),h);
    end
end

save ihavedata polyx polyy;

% 
% function [xred,yred]=DownSample(x,y,minkmsq,thinninglength);
% 
% xkm=x*(40075/360);
% ykm=y*(40075/360);
% 
% AreaSquareDegrees=polyarea(x,y);
% Areakmsq=AreaSquareDegrees*(40075/360)^2*cosd(mean(y));
% 
% 
% if Areakmsq < minkmsq;
%     xred=[];
%     yred=[];
%     return
% end
% 
% if thinninglength ==0
%     xred=x;
%     yred=y;
%     return
% end
% 
% % now go through and smooth over any points that are within 1km of
% % each other.
% 
% MinDistance=thinninglength;
% 
% c=1;
% done=0;
% 
% xred=-190*ones(1,1e5);
% yred=-190*ones(1,1e5);
% 
% xred(1)=x(1);
% yred(1)=y(1);
% xredlength=1;
% 
% while ~done
%     
%     z=((xkm(c:end)-xkm(c)).^2+(ykm(c:end)-ykm(c)).^2).^(1/2);
%     ii=min(find(z>=MinDistance));
%     
%     if ~isempty(ii)
%         xredlength=xredlength+1;
%         xred(xredlength)=x(c+ii-1);
%         yred(xredlength)=y(c+ii-1);
%         
%         c=c+ii-1;
%     else
%         done=1;
%     end
%     
% end
% 
% xred=xred(1:xredlength);
% yred=yred(1:xredlength);
% xred(end+1)=xred(1);
% yred(end+1)=yred(1);    
