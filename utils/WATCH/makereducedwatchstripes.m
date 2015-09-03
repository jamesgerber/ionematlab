function makeralsfjsl
% makereducedWATCHstripes - make a reduced set of stripes

[outline] = CropMaskLogical;
outline30min=aggregate_rate(outline,6);
outline30min=outline30min>0;
 
mm=find(outline30min);
 
mdnstart=datenum(1958,1,1,0,0,0);
length(mm)
for j=1:length(mm)
    try
    [mdnlong,ts1,stripeno]=getstripe(mm(j),'rain');
    [mdnlong,ts2,stripeno]=getstripe(mm(j),'snow');
    [mdnlong,ts3,stripeno]=getstripe(mm(j),'Tair');

    j
    
    ii=find(mdnlong >mdnstart);
    
    rain=ts1(ii);
    mdnvect=mdnlong(ii);
    basedir=[iddstring '/Climate/reanalysis/WATCH_Reduced/Rainf/stripes/'];
    FileBase='rain_pt';
    save([basedir FileBase num2str(stripeno)],'mdnvect','rain');
    
    snow=ts2(ii);
    mdnvect=mdnlong(ii);
    basedir=[iddstring '/Climate/reanalysis/WATCH_Reduced/Snowf/stripes/'];
    FileBase='snow_pt';
    save([basedir FileBase num2str(stripeno)],'mdnvect','snow');
    
    
    Tair=ts3(ii);
    mdnvect=mdnlong(ii);
    basedir=[iddstring '/Climate/reanalysis/WATCH_Reduced/Tair/stripes/'];
    FileBase='Tair_WFD_pt';
    save([basedir FileBase num2str(stripeno)],'mdnvect','Tair');
    catch
        disp(['skipping j = ' num2str(j) ]);
    end

end


return
% code to test

[mdnred,tsred]=getreducedstripe(35692,'Tair');
[mdn,ts]=getstripe(35692,'Tair');
figure
plot(mdnred,tsred,mdn,ts,':')

[mdnred,tsred]=getreducedstripe(35692,'rain');
[mdn,ts]=getstripe(35692,'rain');
figure
plot(mdnred,tsred,mdn,ts,':')


[mdnred,tsred]=getreducedstripe(35692,'snow');
[mdn,ts]=getstripe(35692,'snow');
figure
plot(mdnred,tsred,mdn,ts,':')

