function newlims=AMTSmartCAxisLimit(caxis)
% AMTSMARTCAXISLIMIT - version of SmartCAxisLimit that rounds to the same
% order of magnitude on both sides of 0
%
% SYNTAX
% newlims=AMTSmartCAxisLimit(caxis) - set newlims to 'nice' approximations
% of coloraxis limits caxis.
c1=caxis(1);
c2=caxis(2);

if c1*c2 > 0
    disp(['haven''t yet progammed clims on same side of 0'])
else
    
   if c2 < c1
       error
       return
   end
   
   if (ceil(log10(abs(c2)))-ceil(log10(abs(c1)))==1)
       newc2= RoundUp(c2);
       newc1= -RoundUpRough(-c1);
   else if (ceil(log10(abs(c1)))-ceil(log10(abs(c2)))==1)
       newc2= RoundUpRough(c2);
       newc1= -RoundUp(-c1);
       else
          newc2= RoundUp(c2);
          newc1= -RoundUp(-c1);
       end
   end
   newlims=[newc1 newc2];
   
end
end


function a=RoundUp(x);
% round up x to the nearest value w/ <3 sig figs

order=log10(x);
bigpart=floor(x/10^floor(order));
smallpart=x/10^floor(order)-bigpart;
smallpart=ceil(smallpart*10)/10;
a=(bigpart+smallpart)*10^floor(order);
end

function a=RoundUpRough(x);
% round up x to the nearest value w/ <3 sig figs
order=log10(x);
bigpart=ceil(x/10^floor(order));
a=bigpart*10^floor(order);
end