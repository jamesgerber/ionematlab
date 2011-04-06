function newlims=AMTSmartCaxisLimit(caxis);
c1=caxis(1);
c2=caxis(2);

if c1*c2 > 0
    disp(['haven''t yet progammed clims on same side of 0'])
else
    
   if c2 < c1
       error
       return
   end
   
   
   newc2= RoundUp(c2);
   newc1= -RoundUp(-c1);
   
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